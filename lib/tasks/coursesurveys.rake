# - sudo su www-data and cd into hkn-rails
# - Run with rake coursesurveys:scrape["<url>"]
# - For url, do a search on schedule.berkeley.edu (e.g. for EE or CS department)
#   and take that url. (Should be osoc.berkeley.edu/...)
# - Some instructors may not be auto-identified.  You can manually enter id
#   Find ids in rail console.  (In terminal, "rails c production" to open console.  
#   In console, "Instructor.find_by_last_name("<name>"))

namespace :coursesurveys do

  desc "Scrape a schedule.berkeley url into this semester's course surveys to be surveyed"
  task :scrape, :url, :permit do |t, args|
    unless url = args.url
      puts "Enter the schedule.berkeley url"
      url = $stdin.readline.strip
    end
    permit = args.permit
    puts "Importing from #{url}..."
    importer = CourseSurveys::ScheduleImporter.new(url, permit)
    importer.import!
  end
end
