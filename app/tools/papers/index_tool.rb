# frozen_string_literal: true

module Papers
  class IndexTool < MCP::Tool
    tool_name "paper-index-tool"
    description "List papers. Supports filtering by reading_status (unread/reading/read/to_cite), search query, count (default 10)."
    annotations(
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    input_schema(
      properties: {
        count: { type: "integer" },
        reading_status: { type: "string" },
        search: { type: "string" }
      }
    )

    def self.call(count: 10, reading_status: nil, search: nil, server_context:)
      papers = Paper.all
      papers = papers.by_status(reading_status) if reading_status.present?
      papers = papers.search(search) if search.present?
      papers = papers.last(count)

      response = papers.map(&:to_mcp_response).join("\n")
      response = "Nothing was found" if response.blank?

      MCP::Tool::Response.new([ { type: "text", text: response } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
