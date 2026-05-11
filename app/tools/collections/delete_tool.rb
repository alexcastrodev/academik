# frozen_string_literal: true

module Collections
  class DeleteTool < MCP::Tool
    tool_name "collection-delete-tool"
    description "Delete a Collection entity of the given ID"
    annotations(read_only_hint: false, destructive_hint: true, idempotent_hint: true, open_world_hint: false)

    input_schema(properties: { id: { type: "integer" } }, required: [ "id" ])

    def self.call(id:, server_context:)
      Collection.find(id).destroy!
      MCP::Tool::Response.new([ { type: "text", text: "Collection of id = #{id} was deleted" } ])
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Collection of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
