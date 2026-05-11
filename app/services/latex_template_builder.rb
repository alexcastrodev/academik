class LatexTemplateBuilder
  def initialize(papers)
    @papers = Array(papers)
  end

  def build
    <<~LATEX
      \\documentclass[12pt,a4paper]{article}
      \\usepackage[utf8]{inputenc}
      \\usepackage[T1]{fontenc}
      \\usepackage{hyperref}
      \\usepackage{geometry}
      \\geometry{margin=2.5cm}
      \\usepackage{parskip}

      \\title{#{escape_latex(@papers.size == 1 ? @papers.first.title : "Literature Review")}}
      \\date{\\today}

      \\begin{document}
      \\maketitle
      \\tableofcontents
      \\newpage

      #{sections}

      #{bibliography}

      \\end{document}
    LATEX
  end

  private

  def sections
    @papers.map { |paper| paper_section(paper) }.join("\n\n")
  end

  def paper_section(paper)
    summary_text = paper.latest_summary&.content.presence || "\\textit{No summary generated yet.}"
    authors = paper.authors.presence || "Unknown"
    year = paper.year ? "(#{paper.year})" : ""

    <<~SECTION
      \\section{#{escape_latex(paper.title)}}
      \\textbf{Authors:} #{escape_latex(authors)} #{year}\\\\
      #{paper.journal.present? ? "\\textbf{Journal:} #{escape_latex(paper.journal)}\\\\" : ""}
      #{paper.doi.present? ? "\\textbf{DOI:} \\href{https://doi.org/#{escape_latex(paper.doi)}}{#{escape_latex(paper.doi)}}\\\\" : ""}

      \\subsection*{Abstract}
      #{escape_latex(paper.abstract.to_s)}

      \\subsection*{Summary}
      #{escape_latex(summary_text)}
    SECTION
  end

  def bibliography
    return "" if @papers.empty?

    entries = @papers.map { |p| bibtex_entry(p) }.join("\n\n")

    <<~BIB
      \\begin{thebibliography}{#{@papers.size}}
      #{entries}
      \\end{thebibliography}
    BIB
  end

  def bibtex_entry(paper)
    key = [paper.authors.to_s.split(",").first.to_s.split.last, paper.year].compact.join("")
    key = "ref#{paper.id}" if key.blank?

    "\\bibitem{#{key}} #{escape_latex(paper.authors.to_s)}. \\textit{#{escape_latex(paper.title)}}. #{escape_latex(paper.journal.to_s)}#{paper.year ? ", #{paper.year}" : ""}."
  end

  LATEX_SPECIAL = {
    "\\" => "\\textbackslash{}",
    "&"  => "\\&",
    "%"  => "\\%",
    "$"  => "\\$",
    "#"  => "\\#",
    "_"  => "\\_",
    "^"  => "\\^{}",
    "~"  => "\\~{}",
    "{"  => "\\{",
    "}"  => "\\}"
  }.freeze

  def escape_latex(str)
    str.to_s.gsub(/[\\&%$#_^~{}]/) { |m| LATEX_SPECIAL[m] }
  end
end
