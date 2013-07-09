#Set the load path to the lib directory for the additional class files
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'lib' ) )

require 'rubygems'
require 'biomart'
require 'exon'
require 'interval_list'

transcripts = Array.new
responses = Hash.new
@genes = Hash.new

puts "Reading transcripts"
CSV.foreach("transcript_ids.csv") do |row|
  this_transcript = row.first.strip
  transcripts.push(this_transcript)
end
puts transcripts.inspect
puts "Starting query..."
biomart = Biomart::Server.new("http://www.biomart.org/biomart")
ensembl = biomart.datasets["hsapiens_gene_ensembl"]

puts "Sending query"
transcripts.each do |transcript| 
	if (transcript)&& (!transcript.empty?)
		response = ensembl.search(:filters => {"refseq_mrna" => transcript},:attributes => ["external_gene_id",  "chromosome_name", "strand", "exon_chrom_start", "exon_chrom_end", "rank"])
		if response
			responses[transcript] = response[:data]
			puts "Response for #{transcript}"
		else
			puts "No response for transcript ID #{transcript}"
		end
	end
end

puts responses.inspect

responses.each do |transcript_id, response|
	
	response.each { |row|
		this_exon = Exon.new(row[0], row[1], row[2], row[3], row[4], row[5])
		
		if @genes.has_key?(row[0])
			exon_array = @genes[row[0]]
			exon_array.push(this_exon)
			@genes[row[0]] = exon_array
		else
			exon_array = Array.new
			exon_array.push(this_exon)
			@genes[row[0]] = exon_array
		end
	}
	
	
end

puts @genes.inspect

@genes.each_pair do |gene_name, exons|
	this_interval_list = IntervalList.new(gene_name, exons)
	interval_file = File.new("interval_lists/#{gene_name}.interval_list", "w")
	interval_file.puts this_interval_list.parse_list()
	interval_file.close
end


puts "Done"
