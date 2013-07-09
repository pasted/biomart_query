#!/usr/bin/ruby
class Exon

	attr_accessor :name, :chromosome, :strand, :start, :stop, :rank


	def convert_strand(strand)
		if strand == "1"
			return "+"
		elsif strand == "-1"
			return "-"
		else
			puts "Strand error"
		end
	end

	def output_tsv()
		return "#{self.chromosome}	#{self.start}	#{self.stop}	#{self.strand}	#{self.rank}"
	end

	def initialize(name, chromosome, strand, start, stop, rank)
		self.name = name
		self.chromosome = chromosome
		self.strand = convert_strand(strand)
		self.start = start
		self.stop = stop
		self.rank = rank
	end


end
