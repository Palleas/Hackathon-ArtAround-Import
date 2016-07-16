defmodule ArtaroundImport do

	def main(args) do
		IO.puts "Importing stuff!"
		args |> parse_args |> process
	end

	def process([]) do
		IO.puts "You need to pass the things"
	end

	def process(options) do
		IO.puts "Importing #{options[:path]}"		
		{:ok, content} = File.read(options[:path])
		arts = Poison.Parser.parse!(content)


		cleaned_list = Enum.map(arts, fn row -> 
			IO.puts "Current: #{row["Titre"]}" 

			cleaned = %{
				:id => row["NoInterne"],
				:title => row["Titre"],
				:position => %{
					:lat => String.strip(row["CoordonneeLatitude"]),
					:lon => String.strip(row["CoordonneeLongitude"])
				},
				:category => row["SousCategorieObjet"],
				:materials => extract_materials(row["Materiaux"])
			}
			cleaned
		end)

		json_file = Poison.Encoder.encode(%{:places => cleaned_list}, [])
		File.write!("export.json", json_file, [])
	end

	def extract_materials(nil) do
		[]
	end
	
	def extract_materials(materials) do
		Enum.map(String.split(materials, ";"), fn material -> String.strip(material) end)
	end
	
	defp parse_args(args) do
		{options, _, _} = OptionParser.parse(args,
			switches: [path: :string]
		)
		options
	end
end
