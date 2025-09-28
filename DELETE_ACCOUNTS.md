# Account Deletion Guide

This guide explains how to delete all accounts and their associated data in the SaaS Time Tracker application.

## Overview

The Time Tracker application uses multi-tenancy with the Apartment gem, where each account gets its own PostgreSQL schema. When deleting accounts, both the account records and their associated database schemas need to be cleaned up.

## Methods Available

### 1. Web Interface

Visit the main application URL (without subdomain) and you'll see an "Account Management" panel if accounts exist. This provides:

- Display of total number of accounts
- A "Delete All Accounts" button with double confirmation
- Requires manual confirmation checkbox to prevent accidental deletion

### 2. Rake Tasks

#### Interactive Deletion
```bash
rake delete_all_accounts
```
This will:
- Prompt for confirmation (`yes`/`no`)
- Show progress for each account being deleted
- Report success/failure counts
- Handle errors gracefully

#### Non-Interactive Deletion (for scripts)
```bash
rake force_delete_all_accounts
```
This will delete all accounts without prompting (use with extreme caution).

### 3. Rails Console

You can also use the Rails console for more fine-grained control:

```ruby
# Delete all accounts with their schemas
Account.delete_all_with_schemas!

# Delete a specific account with its schema
account = Account.find_by(subdomain: 'example')
account.destroy_with_schema!

# Standard deletion (will also trigger schema cleanup via callback)
account.destroy!
```

## What Gets Deleted

When an account is deleted:

1. **Database Schema**: The PostgreSQL schema containing all tenant data (users, projects, etc.)
2. **Account Record**: The account record in the main database
3. **All Associated Data**: Everything within the tenant schema is permanently removed

## Safety Features

- Double confirmation in web interface
- Interactive confirmation in rake tasks
- Transactional deletion (account + schema deleted together)
- Error handling and reporting
- Graceful handling of missing schemas

## Recovery

⚠️ **WARNING**: There is no recovery mechanism. Once accounts are deleted, all data is permanently lost.

## Example Usage

```bash
# Check how many accounts exist
rails console -e production
> Account.count

# Delete all accounts interactively
rake delete_all_accounts RAILS_ENV=production

# Or use the web interface by visiting your domain without a subdomain
```

## Technical Details

- Uses Apartment gem's `drop` method to remove schemas
- Checks for schema existence before attempting deletion
- Compatible with older Apartment gem versions
- Handles PostgreSQL schema management directly when needed