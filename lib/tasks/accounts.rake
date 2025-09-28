desc 'Delete all accounts and associated database schemas'
task :delete_all_accounts => :environment do
  puts "WARNING: This will delete ALL accounts and their data!"
  puts "Are you sure you want to continue? (yes/no)"
  
  # For non-interactive mode, we'll assume yes if FORCE_DELETE_ALL is set
  confirmation = ENV['FORCE_DELETE_ALL'] == 'true' ? 'yes' : STDIN.gets.chomp.downcase
  
  if confirmation == 'yes'
    puts "Deleting all accounts..."
    
    deleted_count = 0
    failed_deletions = []
    
    Account.find_each do |account|
      begin
        puts "Deleting account: #{account.subdomain}"
        
        # Use the Account model's method for consistent schema checking
        account.destroy_with_schema!
        puts "  - Successfully deleted account and schema: #{account.subdomain}"
        
        deleted_count += 1
        
      rescue => e
        puts "  - ERROR deleting account #{account.subdomain}: #{e.message}"
        failed_deletions << { subdomain: account.subdomain, error: e.message }
      end
    end
    
    puts "\nDeletion complete!"
    puts "Successfully deleted: #{deleted_count} accounts"
    
    if failed_deletions.any?
      puts "Failed deletions:"
      failed_deletions.each do |failure|
        puts "  - #{failure[:subdomain]}: #{failure[:error]}"
      end
    end
    
    puts "Remaining accounts: #{Account.count}"
    
  else
    puts "Deletion cancelled."
  end
end

desc 'Force delete all accounts without confirmation (use with caution!)'
task :force_delete_all_accounts do
  ENV['FORCE_DELETE_ALL'] = 'true'
  Rake::Task[:delete_all_accounts].invoke
end