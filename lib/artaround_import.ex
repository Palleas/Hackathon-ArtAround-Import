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
					:lon => String.strip(row["CoordonneeLongitude"]),
				}
			}
			cleaned
		end)

		json_file = Poison.Encoder.encode(%{:places => cleaned_list}, [])
		File.write!("export.json", json_file, [])
	end

	defp parse_args(args) do
		{options, _, _} = OptionParser.parse(args,
			switches: [path: :string]
		)
		options
	end
end
