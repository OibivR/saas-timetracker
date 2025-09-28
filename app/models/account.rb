class Account < ActiveRecord::Base
  RESTRICTED_SUBDOMAINS = %w(www)

  belongs_to :owner, class_name: 'User'

  validates :owner, presence: true
  validates :subdomain, presence: true,
                        uniqueness: { case_sensitive: false },
                        format: { with: /\A[\w\-]+\Z/i, message: 'contains invalid characters' },
                        exclusion: { in: RESTRICTED_SUBDOMAINS, message: 'restricted' }

  accepts_nested_attributes_for :owner

  before_validation :downcase_subdomain
  before_destroy :drop_associated_schema

  def self.delete_all_with_schemas!
    find_each do |account|
      account.destroy_with_schema!
    end
  end

  def destroy_with_schema!
    transaction do
      # Drop the apartment database schema first
      if schema_exists?
        Apartment::Database.drop(subdomain)
      end
      
      # Then destroy the account record
      destroy!
    end
  end

private
  def downcase_subdomain
    self.subdomain = subdomain.try(:downcase)
  end

  def drop_associated_schema
    if subdomain.present? && schema_exists?
      Apartment::Database.drop(subdomain)
    end
  end

  def schema_exists?
    return false if subdomain.blank?
    
    # Check if schema exists by querying PostgreSQL directly
    # since older Apartment versions may not have schema_exists? method
    ActiveRecord::Base.connection.execute(
      "SELECT 1 FROM information_schema.schemata WHERE schema_name = '#{subdomain}'"
    ).count > 0
  rescue
    false
  end
end
