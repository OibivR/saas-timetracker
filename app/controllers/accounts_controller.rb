class AccountsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:new, :create]

  def new
    @account = Account.new
    @account.build_owner
  end

  def create
    @account = Account.new(account_params)
    if @account.valid?
      Apartment::Database.create(@account.subdomain)
      Apartment::Database.switch(@account.subdomain)
      @account.save
      redirect_to new_user_session_url(subdomain: @account.subdomain)
    else
      render action: 'new'
    end
  end

  def delete_all
    if params[:confirm] == 'yes'
      deleted_count = Account.count
      begin
        Account.delete_all_with_schemas!
        redirect_to root_path, notice: "Successfully deleted #{deleted_count} accounts and their data."
      rescue => e
        redirect_to root_path, alert: "Error deleting accounts: #{e.message}"
      end
    else
      redirect_to root_path, alert: "Account deletion cancelled."
    end
  end

private
  def account_params
    params.require(:account).permit(:subdomain, owner_attributes: [:name, :email, :password, :password_confirmation])
  end
end