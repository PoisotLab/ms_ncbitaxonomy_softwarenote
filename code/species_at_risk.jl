using NCBITaxonomy
import Downloads
import CSV

# Get the CAN-SAR data
cansar_csv = joinpath(splitpath(@__FILE__)[1:(end-1)]..., "cansar.csv")

# DO NOT download the file, it is corrupted
#Downloads.download("https://osf.io/download/jv5w6/", cansar_csv)

# Load the data
CANSAR = CSV.File(cansar_csv)

at_risk = unique(CANSAR.species)

no_match = 0
mis_match = 0
has_match = 0
other_error = 0

@profview for name in at_risk
    try
        tax = taxon(name; casesensitive=true, preferscientific=true)
        if tax.name != name
            mis_match += 1
        else
            has_match += 1
        end
    catch err
        if err isa NameHasNoDirectMatch
            no_match += 1
        else
            other_error += 1
        end
    end
end

@info "Correct name: $(has_match)"
@info "Synonym: $(mis_match)"
@info "No match: $(no_match)"
@info "Other error: $(other_error)"