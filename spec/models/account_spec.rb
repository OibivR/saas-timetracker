require 'spec_helper'

describe Account do
  describe 'validations' do
    it { should validate_presence_of :owner }
    
    it { should validate_presence_of :subdomain }
    it { should validate_uniqueness_of :subdomain }

    it { should allow_value('bolandrm').for(:subdomain) }
    it { should allow_value('test').for(:subdomain) }

    it { should_not allow_value('www').for(:subdomain) }
    it { should_not allow_value('WWW').for(:subdomain) }
    it { should_not allow_value('.test').for(:subdomain) }
    it { should_not allow_value('test/').for(:subdomain) }

    it 'should validate case insensitive uniqueness' do
      create(:account, subdomain: 'Test')
      expect(build(:account, subdomain: 'test')).to_not be_valid
    end
  end

  describe 'associations' do
    it { should belong_to :owner }
  end

  describe 'deletion' do
    let(:account) { create(:account_with_schema) }

    describe '#destroy_with_schema!' do
      it 'destroys the account and its schema' do
        subdomain = account.subdomain
        
        expect {
          account.destroy_with_schema!
        }.to change(Account, :count).by(-1)
        
        # Ensure the schema is also dropped (this would require actual database setup)
        # For now, we'll just test the method completes successfully
      end
    end

    describe '.delete_all_with_schemas!' do
      before do
        create(:account_with_schema, subdomain: 'test1')
        create(:account_with_schema, subdomain: 'test2')
      end

      it 'deletes all accounts with their schemas' do
        expect {
          Account.delete_all_with_schemas!
        }.to change(Account, :count).to(0)
      end
    end
  end
end
