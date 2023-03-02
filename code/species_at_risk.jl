using Cascadia, Gumbo, HTTP
using AbstractTrees
using NCBITaxonomy

# List of wildlife species at risk
wsr_url = "https://laws.justice.gc.ca/eng/acts/s-15.3/page-10.html"

# Get the text of the page
req = HTTP.get(wsr_url)
str = split(String(req.body), "\r\n")
filter!(s -> contains(s, "otherLang"), str)

binomialfinder = r"(?:var \.\s?){0}<span class=\"otherLang\" lang=\"la\">(?<genus>\w+)\s{1}(?<species>\w+)<\/span>"

wsr = sort(unique([m["genus"] * " " * m["species"] for m in collect(eachmatch(binomialfinder, str[1]))]))

ding = 0
for name in wsr
    try
        tax = taxon(name; casesensitive=true, preferscientific=false)
    catch err
        ding += 1
        if err isa NameHasNoDirectMatch
            @info "$(name) not found with no direct match"
            for sn in similarnames(name)
                @info "\t$(sn)"
            end
        end
    end
end
@info ding