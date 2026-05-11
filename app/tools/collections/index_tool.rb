# frozen_string_literal: true

module Collections
  class IndexTool < MCP::Tool
    tool_name "collection-index-tool"
    description "List the last count of Collection entities. The count parameter is an integer and defaults to 10. parent_id may be used to filter by parent collection."
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    input_schema(
      properties: {
        count: { type: "integer" },
        parent_id: { type: "integer" }
      }
    )

    def self.call(count: 10, parent_id: nil, server_context:)
      collections = Collection.all
      collections = collections.where(parent_id: parent_id) if parent_id.present?
      collections = collections.last(count)
      response = collections.map(&:to_mcp_response).join("\n")
      response = "Nothing was found" if response.blank?
      MCP::Tool::Response.new([ { type: "text", text: response } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
