require 'httparty'

desc "Get users from code wars"
task get_code_wars_users: :environment do

  counter = 0

  Profile.all.each_with_index do |profile, index|
    begin
      counter += 1

      if counter >= 200
        sleep 3.minutes
        counter = 0
      end

      if CodeWarsDatum.where(profile_id: profile.id).count > 0
        puts "already has profile #{index}"
        next
      end

      response = HTTParty.get("https://www.codewars.com/api/v1/users/#{profile.username}?access_key=#{ENV['CODEWARS_TOKEN']}").to_json
      parsed_response = JSON.parse(response, quirks_mode: true)

      if parsed_response["success"] == false
        puts "non-existent profile #{index}"
        next
      else
        languages = parsed_response["ranks"]["languages"].keys
      end

      CodeWarsDatum.where(
        profile_id: profile.id
      ).first_or_create(
        username: profile.username,
        honor: parsed_response["honor"],
        languages: languages,
        challenges_completed: parsed_response["codeChallenges"]["totalCompleted"]
      )

      puts "added code wars profile #{index}"
    rescue => e
      p "an error occurred: #{e}"
    end
  end

end
