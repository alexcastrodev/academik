# frozen_string_literal: true

module Tags
  class IndexTool < MCP::Tool
    tool_name "tag-index-tool"
    description "List the last count of Tag entities. The count parameter is an integer and defaults to 10."
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    input_schema(properties: { count: { type: "integer" } })

    def self.call(count: 10, server_context:)
      tags = Tag.all.last(count)
      response = tags.map(&:to_mcp_response).join("\n")
      response = "Nothing was found" if response.blank?
      MCP::Tool::Response.new([ { type: "text", text: response } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
