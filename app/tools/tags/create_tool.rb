# frozen_string_literal: true

module Tags
  class CreateTool < MCP::Tool
    tool_name "tag-create-tool"
    description "Create a new Tag entity"
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: false, open_world_hint: false)

    input_schema(
      properties: {
        name: { type: "string" },
        color: { type: "string" }
      },
      required: [ "name" ]
    )

    def self.call(name: nil, color: nil, server_context:)
      tag = Tag.new(name: name, color: color || "#6366f1")
      if tag.save
        MCP::Tool::Response.new([ { type: "text", text: "Created #{tag.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Tag was not created due to: #{tag.errors.full_messages.join(', ')}" } ])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
