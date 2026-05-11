class DoiResolverService
  CROSSREF_API = "https://api.crossref.org"
  ARXIV_API    = "https://export.arxiv.org/api/query"

  def initialize(input)
    @input = input.to_s.strip
  end

  def resolve
    if arxiv_id
      resolve_arxiv(arxiv_id)
    else
      resolve_doi(clean_doi)
    end
  rescue Faraday::Error, JSON::ParserError
    nil
  end

  private

  # Extracts arxiv ID from URLs like:
  #   https://arxiv.org/abs/2411.17710
  #   https://arxiv.org/pdf/2411.17710
  #   https://arxiv.org/pdf/2411.17710v1
  #   arxiv:2411.17710
  def arxiv_id
    @arxiv_id ||= begin
      if @input.match?(%r{arxiv\.org/(abs|pdf)/}i)
        @input.sub(%r{.*arxiv\.org/(?:abs|pdf)/}, "").sub(/\.pdf$/i, "")
      elsif @input.match?(/\Aarxiv:/i)
        @input.sub(/\Aarxiv:/i, "")
      end
    end
  end

  def clean_doi
    @input.sub(%r{\Ahttps?://doi\.org/}, "")
  end

  def resolve_arxiv(id)
    conn = Faraday.new(url: ARXIV_API)
    response = conn.get("", id_list: id, max_results: 1)
    return nil unless response.success?

    doc = Nokogiri::XML(response.body)
    doc.remove_namespaces!
    entry = doc.at("entry")
    return nil unless entry

    authors = entry.css("author name").map(&:text).join(", ")
    published = entry.at("published")&.text
    year = published&.slice(0, 4)&.to_i

    # arxiv DOI link, if present
    doi = entry.css("link[title='doi']").first&.attr("href")
           &.sub(%r{https?://doi\.org/}, "")

    {
      title:    entry.at("title")&.text&.strip&.gsub(/\s+/, " "),
      authors:  authors.presence,
      year:     year,
      journal:  "arXiv",
      doi:      doi,
      abstract: entry.at("summary")&.text&.strip&.gsub(/\s+/, " "),
      pdf_url:  (entry.css("link[type='application/pdf']").first&.attr("href") || "https://arxiv.org/pdf/#{id}")
    }.compact
  end

  def resolve_doi(doi)
    return nil if doi.blank?

    conn = Faraday.new(url: CROSSREF_API)
    response = conn.get("/works/#{doi}")
    return nil unless response.success?

    data = JSON.parse(response.body).dig("message")
    return nil unless data

    map_crossref(data, doi)
  end

  def map_crossref(data, doi)
    authors  = Array(data["author"]).map { |a| [a["given"], a["family"]].compact.join(" ") }.join(", ")
    year     = data.dig("issued", "date-parts", 0, 0)
    pdf_url  = Array(data["link"]).find { |l| l["content-type"] == "application/pdf" }&.dig("URL")

    {
      title:    Array(data["title"]).first,
      authors:  authors.presence,
      year:     year,
      journal:  Array(data["container-title"]).first,
      doi:      doi,
      abstract: data["abstract"],
      pdf_url:  pdf_url
    }.compact
  end
end
