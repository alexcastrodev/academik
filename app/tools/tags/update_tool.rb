# frozen_string_literal: true

module Tags
  class UpdateTool < MCP::Tool
    tool_name "tag-update-tool"
    description "Update a Tag entity of a given ID"
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    input_schema(
      properties: {
        id: { type: "integer" },
        name: { type: "string" },
        color: { type: "string" }
      },
      required: [ "id" ]
    )

    def self.call(id:, name: MCP::EmptyProperty, color: MCP::EmptyProperty, server_context:)
      tag = Tag.find(id)
      tag.name = name unless name == MCP::EmptyProperty
      tag.color = color unless color == MCP::EmptyProperty

      if tag.save
        MCP::Tool::Response.new([ { type: "text", text: "Updated #{tag.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Tag of id = #{id} was not updated due to: #{tag.errors.full_messages.join(', ')}" } ])
      end
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Tag of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
