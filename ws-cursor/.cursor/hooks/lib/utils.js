/**
 * Utility functions for Cursor Langfuse hooks
 */

/**
 * Read and parse JSON input from stdin
 * Cursor hooks pass data via stdin as JSON
 * @returns {Promise<object>} Parsed JSON object from stdin
 */
export async function readStdin() {
  return new Promise((resolve, reject) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => {
      data += chunk;
    });
    process.stdin.on('end', () => {
      try {
        resolve(JSON.parse(data));
      } catch (e) {
        reject(new Error(`Failed to parse JSON from stdin: ${e.message}`));
      }
    });
    process.stdin.on('error', reject);
  });
}

/**
 * Generate a descriptive trace name from the prompt
 * @param {string} prompt - The user's prompt text
 * @param {string} model - The model being used
 * @returns {string} A descriptive trace name
 */
export function generateTraceName(prompt, model) {
  if (!prompt) {
    return `Cursor ${model || 'Agent'}`;
  }
  
  // Extract first meaningful words from the prompt (max 50 chars)
  const cleaned = prompt
    .replace(/\n/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  
  const maxLength = 50;
  if (cleaned.length <= maxLength) {
    return cleaned;
  }
  
  // Try to cut at a word boundary
  const truncated = cleaned.substring(0, maxLength);
  const lastSpace = truncated.lastIndexOf(' ');
  
  if (lastSpace > 30) {
    return truncated.substring(0, lastSpace) + '...';
  }
  
  return truncated + '...';
}

/**
 * Generate a session ID from workspace roots
 * Groups all conversations in the same workspace together
 * @param {string[]} workspaceRoots - Array of workspace root paths
 * @returns {string} Session ID
 */
export function generateSessionId(workspaceRoots) {
  if (!workspaceRoots || workspaceRoots.length === 0) {
    return 'cursor-default-session';
  }
  
  // Use the first workspace root as the session identifier
  // Extract just the folder name for cleaner session names
  const root = workspaceRoots[0];
  const folderName = root.split('/').pop() || root;
  
  return `cursor-${folderName}`;
}

/**
 * Generate dynamic tags based on hook activity
 * @param {string} hookName - The name of the hook being executed
 * @param {object} input - The input data from the hook
 * @param {Set<string>} existingTags - Set of existing tags to add to
 * @returns {string[]} Array of tags
 */
export function generateTags(hookName, input, existingTags = new Set()) {
  const tags = new Set(existingTags);
  
  // Always add cursor tag
  tags.add('cursor');
  
  // Add agent or tab tag based on hook type
  if (hookName.includes('Tab')) {
    tags.add('tab');
  } else {
    tags.add('agent');
  }
  
  // Add model-specific tag
  if (input.model) {
    // Normalize model name to a tag-friendly format
    const modelTag = input.model
      .toLowerCase()
      .replace(/[^a-z0-9-]/g, '-')
      .replace(/-+/g, '-')
      .substring(0, 30);
    tags.add(modelTag);
  }
  
  // Add hook-type specific tags
  switch (hookName) {
    case 'beforeShellExecution':
    case 'afterShellExecution':
      tags.add('shell');
      break;
    case 'beforeMCPExecution':
    case 'afterMCPExecution':
      tags.add('mcp');
      if (input.tool_name) {
        tags.add(`mcp-${input.tool_name.toLowerCase().substring(0, 20)}`);
      }
      break;
    case 'beforeReadFile':
    case 'afterFileEdit':
    case 'beforeTabFileRead':
    case 'afterTabFileEdit':
      tags.add('file-ops');
      break;
    case 'afterAgentThought':
      tags.add('thinking');
      break;
  }
  
  return Array.from(tags);
}

/**
 * Determine the observation level based on status or context
 * @param {string} status - The status (e.g., 'completed', 'error', 'aborted')
 * @param {boolean} isBlocked - Whether the operation was blocked
 * @returns {string} Level: 'DEBUG' | 'DEFAULT' | 'WARNING' | 'ERROR'
 */
export function determineLevel(status, isBlocked = false) {
  if (isBlocked) {
    return 'WARNING';
  }
  
  switch (status) {
    case 'error':
      return 'ERROR';
    case 'aborted':
      return 'WARNING';
    case 'completed':
    default:
      return 'DEFAULT';
  }
}

/**
 * Calculate edit statistics from an array of edits
 * @param {Array<{old_string: string, new_string: string}>} edits - Array of edits
 * @returns {object} Edit statistics
 */
export function calculateEditStats(edits) {
  if (!edits || !Array.isArray(edits)) {
    return { editCount: 0, linesAdded: 0, linesRemoved: 0 };
  }
  
  let linesAdded = 0;
  let linesRemoved = 0;
  
  for (const edit of edits) {
    const oldLines = (edit.old_string || '').split('\n').length;
    const newLines = (edit.new_string || '').split('\n').length;
    
    if (newLines > oldLines) {
      linesAdded += newLines - oldLines;
    } else if (oldLines > newLines) {
      linesRemoved += oldLines - newLines;
    }
  }
  
  return {
    editCount: edits.length,
    linesAdded,
    linesRemoved,
    netChange: linesAdded - linesRemoved,
  };
}

/**
 * Extract file extension from a file path
 * @param {string} filePath - The file path
 * @returns {string} The file extension (without dot) or 'unknown'
 */
export function getFileExtension(filePath) {
  if (!filePath) return 'unknown';
  
  const parts = filePath.split('.');
  if (parts.length < 2) return 'unknown';
  
  return parts.pop().toLowerCase();
}

/**
 * Format duration in milliseconds to a human-readable string
 * @param {number} ms - Duration in milliseconds
 * @returns {string} Formatted duration
 */
export function formatDuration(ms) {
  if (!ms || ms < 0) return '0ms';
  
  if (ms < 1000) {
    return `${ms}ms`;
  }
  
  if (ms < 60000) {
    return `${(ms / 1000).toFixed(1)}s`;
  }
  
  const minutes = Math.floor(ms / 60000);
  const seconds = ((ms % 60000) / 1000).toFixed(0);
  return `${minutes}m ${seconds}s`;
}

