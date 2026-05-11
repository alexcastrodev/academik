# frozen_string_literal: true

module Collections
  class CreateTool < MCP::Tool
    tool_name "collection-create-tool"
    description "Create a new Collection entity"
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: false, open_world_hint: false)

    input_schema(
      properties: {
        name: { type: "string" },
        description: { type: "string" },
        parent_id: { type: "integer" }
      },
      required: [ "name" ]
    )

    def self.call(name: nil, description: nil, parent_id: nil, server_context:)
      collection = Collection.new(name: name, description: description, parent_id: parent_id)
      if collection.save
        MCP::Tool::Response.new([ { type: "text", text: "Created #{collection.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Collection was not created due to: #{collection.errors.full_messages.join(', ')}" } ])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
