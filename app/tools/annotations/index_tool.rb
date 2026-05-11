# frozen_string_literal: true

module Annotations
  class IndexTool < MCP::Tool
    tool_name "annotation-index-tool"
    description "List the last count of Annotation entities. The count parameter is an integer and defaults to 10. paper_id may be used to filter by paper."
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    input_schema(
      properties: {
        count: { type: "integer" },
        paper_id: { type: "integer" }
      }
    )

    def self.call(count: 10, paper_id: nil, server_context:)
      annots = Annotation.all
      annots = annots.where(paper_id: paper_id) if paper_id.present?
      annots = annots.last(count)
      response = annots.map(&:to_mcp_response).join("\n")
      response = "Nothing was found" if response.blank?
      MCP::Tool::Response.new([ { type: "text", text: response } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
