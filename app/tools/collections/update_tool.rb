# frozen_string_literal: true

module Collections
  class UpdateTool < MCP::Tool
    tool_name "collection-update-tool"
    description "Update a Collection entity of a given ID"
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    input_schema(
      properties: {
        id: { type: "integer" },
        name: { type: "string" },
        description: { type: "string" },
        parent_id: { type: "integer" }
      },
      required: [ "id" ]
    )

    def self.call(id:, name: MCP::EmptyProperty, description: MCP::EmptyProperty, parent_id: MCP::EmptyProperty, server_context:)
      collection = Collection.find(id)
      collection.name = name unless name == MCP::EmptyProperty
      collection.description = description unless description == MCP::EmptyProperty
      collection.parent_id = parent_id unless parent_id == MCP::EmptyProperty

      if collection.save
        MCP::Tool::Response.new([ { type: "text", text: "Updated #{collection.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Collection of id = #{id} was not updated due to: #{collection.errors.full_messages.join(', ')}" } ])
      end
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Collection of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
