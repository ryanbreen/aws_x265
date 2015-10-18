
def usage
  puts "process_video.rb [video filename]"
  exit
end

usage unless ARGV.length == 1

file = ARGV[0]
target_name = "#{File.basename(file, File.extname(file))}.x265.mkv"
puts "Converting #{file} to #{target_name}"

# Copy movie to S3
system "aws s3 cp \"#{file}\" s3://ryanbreen.media/"

# Run VM
system({"INPUT_FILE" => file, "TARGET_NAME" => target_name}, "vagrant up --provider=aws")

# Destroy VM
system "vagrant destroy -f"

# Copy movie down
system "aws s3 cp s3://ryanbreen.media/#{target_name} #{File.dirname(file)}"