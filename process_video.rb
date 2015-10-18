
def usage
  puts "process_video.rb [video filename]"
  exit
end

require 'fileutils'

usage unless ARGV.length == 1

file = ARGV[0]
target_file = "#{File.basename(file, File.extname(file))}.x265.mkv"
puts "Converting #{file} to #{target_file}"

# If the file hasn't already been copied to S3, do so now.
s3_size = `aws s3 ls "s3://ryanbreen.media/#{File.basename(file)}" | cut -d\\  -f 3`
local_size = `ls -l "#{file}" | cut -d\\  -f 8`
if s3_size != local_size
  # Copy movie to S3
  system "aws s3 cp \"#{file}\" s3://ryanbreen.media/"
end

# Run VM
system({"INPUT_FILE" => File.basename(file), "TARGET_FILE" => target_file}, "vagrant up --provider=aws")

# Destroy VM
system "vagrant destroy -f"

# Copy movie down
system "aws s3 cp \"s3://ryanbreen.media/#{target_file}\" \"#{File.dirname(file)}\""

FileUtils.touch File.join(File.dirname(file), target_file), :mtime => File.mtime(file)