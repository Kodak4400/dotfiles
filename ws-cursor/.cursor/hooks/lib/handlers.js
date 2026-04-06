/**
 * Hook Handlers Module
 * Contains handlers for all Cursor hook events.
 */

import {
  calculateEditStats,
  getFileExtension,
  formatDuration,
  determineLevel,
  generateTags,
} from "./utils.js";
import { addCompletionScores, addTagsToTrace } from "./langfuse-client.js";

export function handleBeforeSubmitPrompt(trace, input) {
  trace.update({
    name: input.prompt?.substring(0, 100) || "User Prompt",
    input: input.prompt,
  });

  const generation = trace.generation({
    name: "User Prompt",
    input: input.prompt,
    model: input.model,
    metadata: {
      generation_id: input.generation_id,
      attachment_count: input.attachments?.length || 0,
      attachments: input.attachments?.map((a) => ({
        type: a.type,
        path: a.filePath,
        extension: getFileExtension(a.filePath),
      })),
    },
  });

  if (input.attachments?.length > 0) {
    for (const attachment of input.attachments) {
      generation
        .span({
          name: `Attachment: ${attachment.type}`,
          input: {
            type: attachment.type,
            filePath: attachment.filePath,
            extension: getFileExtension(attachment.filePath),
          },
        })
        .end();
    }
  }

  return { continue: true };
}

export function handleAfterAgentResponse(trace, input) {
  const responseLength = input.text?.length || 0;
  const lineCount = input.text?.split("\n").length || 0;

  trace.update({ output: input.text });

  trace.generation({
    name: "Agent Response",
    output: input.text,
    model: input.model,
    metadata: {
      generation_id: input.generation_id,
      response_length: responseLength,
      line_count: lineCount,
    },
  });

  return null;
}

export function handleAfterAgentThought(trace, input) {
  trace
    .span({
      name: "Agent Thinking",
      input: { type: "thinking" },
      output: input.text,
      metadata: {
        generation_id: input.generation_id,
        duration_ms: input.duration_ms,
        duration_formatted: formatDuration(input.duration_ms),
        thinking_length: input.text?.length || 0,
      },
    })
    .end();

  addTagsToTrace(trace, generateTags("afterAgentThought", input));
  return null;
}

export function handleBeforeShellExecution(trace, input) {
  trace
    .span({
      name: `Shell: ${input.command?.substring(0, 50) || "command"}`,
      input: { command: input.command, cwd: input.cwd },
      metadata: {
        generation_id: input.generation_id,
        command_length: input.command?.length || 0,
      },
    })
    .end();

  addTagsToTrace(trace, generateTags("beforeShellExecution", input));
  return { permission: "allow" };
}

export function handleAfterShellExecution(trace, input) {
  const outputLower = (input.output || "").toLowerCase();
  const mightHaveFailed =
    outputLower.includes("error") ||
    outputLower.includes("failed") ||
    outputLower.includes("not found");

  trace
    .span({
      name: `Shell Result: ${input.command?.substring(0, 40) || "command"}`,
      input: { command: input.command },
      output: input.output,
      level: mightHaveFailed ? "WARNING" : "DEFAULT",
      metadata: {
        generation_id: input.generation_id,
        duration_ms: input.duration,
        duration_formatted: formatDuration(input.duration),
        output_length: input.output?.length || 0,
        might_have_failed: mightHaveFailed,
      },
    })
    .end();

  return null;
}

export function handleBeforeMCPExecution(trace, input) {
  trace
    .span({
      name: `MCP: ${input.tool_name || "tool"}`,
      input: {
        tool_name: input.tool_name,
        tool_input: input.tool_input,
        server_url: input.url,
        server_command: input.command,
      },
      metadata: { generation_id: input.generation_id },
    })
    .end();

  addTagsToTrace(trace, generateTags("beforeMCPExecution", input));
  return { permission: "allow" };
}

export function handleAfterMCPExecution(trace, input) {
  let resultSize = 0;
  try {
    resultSize = JSON.stringify(input.result_json).length;
  } catch {
    resultSize = String(input.result_json).length;
  }

  trace
    .span({
      name: `MCP Result: ${input.tool_name || "tool"}`,
      input: { tool_name: input.tool_name, tool_input: input.tool_input },
      output: input.result_json,
      metadata: {
        generation_id: input.generation_id,
        duration_ms: input.duration,
        duration_formatted: formatDuration(input.duration),
        result_size: resultSize,
      },
    })
    .end();

  return null;
}

export function handleBeforeReadFile(trace, input) {
  const extension = getFileExtension(input.file_path);

  trace
    .span({
      name: `Read: ${input.file_path?.split("/").pop() || "file"}`,
      input: { file_path: input.file_path, extension },
      metadata: { generation_id: input.generation_id, file_extension: extension },
    })
    .end();

  addTagsToTrace(trace, generateTags("beforeReadFile", input));
  return { permission: "allow" };
}

export function handleAfterFileEdit(trace, input) {
  const extension = getFileExtension(input.file_path);
  const editStats = calculateEditStats(input.edits);
  const fileName = input.file_path?.split("/").pop() || "file";

  trace
    .span({
      name: `Edit: ${fileName}`,
      input: { file_path: input.file_path, extension },
      output: {
        edit_count: editStats.editCount,
        lines_added: editStats.linesAdded,
        lines_removed: editStats.linesRemoved,
        net_change: editStats.netChange,
        edits: input.edits,
      },
      metadata: { generation_id: input.generation_id, file_extension: extension, ...editStats },
    })
    .end();

  return null;
}

export function handleStop(trace, input) {
  const level = determineLevel(input.status);

  trace.event({
    name: "Agent Stopped",
    level,
    metadata: {
      status: input.status,
      loop_count: input.loop_count,
      generation_id: input.generation_id,
    },
  });

  addCompletionScores(trace, input);
  addTagsToTrace(trace, [`status-${input.status}`]);

  return {};
}

export function handleBeforeTabFileRead(trace, input) {
  const extension = getFileExtension(input.file_path);
  const fileName = input.file_path?.split("/").pop() || "file";

  trace
    .span({
      name: `Tab Read: ${fileName}`,
      input: { file_path: input.file_path, extension },
      metadata: { generation_id: input.generation_id, file_extension: extension, source: "tab" },
    })
    .end();

  return { permission: "allow" };
}

export function handleAfterTabFileEdit(trace, input) {
  const extension = getFileExtension(input.file_path);
  const editStats = calculateEditStats(input.edits);
  const fileName = input.file_path?.split("/").pop() || "file";

  trace
    .span({
      name: `Tab Edit: ${fileName}`,
      input: { file_path: input.file_path, extension },
      output: {
        edit_count: editStats.editCount,
        edits: input.edits?.map((e) => ({
          range: e.range,
          old_line: e.old_line,
          new_line: e.new_line,
        })),
      },
      metadata: {
        generation_id: input.generation_id,
        file_extension: extension,
        source: "tab",
        ...editStats,
      },
    })
    .end();

  return null;
}

export function routeHookHandler(hookName, trace, input) {
  const handlers = {
    beforeSubmitPrompt: handleBeforeSubmitPrompt,
    afterAgentResponse: handleAfterAgentResponse,
    afterAgentThought: handleAfterAgentThought,
    beforeShellExecution: handleBeforeShellExecution,
    afterShellExecution: handleAfterShellExecution,
    beforeMCPExecution: handleBeforeMCPExecution,
    afterMCPExecution: handleAfterMCPExecution,
    beforeReadFile: handleBeforeReadFile,
    afterFileEdit: handleAfterFileEdit,
    stop: handleStop,
    beforeTabFileRead: handleBeforeTabFileRead,
    afterTabFileEdit: handleAfterTabFileEdit,
  };

  const handler = handlers[hookName];
  if (!handler) {
    console.error(`Unknown hook type: ${hookName}`);
    return null;
  }

  return handler(trace, input);
}
