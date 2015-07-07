Sequel.migration do
  change do
    create_table(:curators) do
      String :id, :null=>false
      String :facebook_identifier, :text=>true, :null=>false
      DateTime :last_curated_at
      DateTime :created_at
      DateTime :updated_at
      
      primary_key [:id]
    end
    
    create_table(:interests, :ignore_index_errors=>true) do
      String :id, :null=>false
      String :name, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      String :stems, :default=>"{}"
      TrueClass :published, :default=>false, :null=>false
      
      primary_key [:id]
      
      index [:name], :name=>:interests_name_key, :unique=>true
      index [:stems]
    end
    
    create_table(:links, :ignore_index_errors=>true) do
      String :id, :null=>false
      String :url, :text=>true, :null=>false
      String :title, :text=>true
      String :description, :text=>true
      DateTime :extracted_at
      DateTime :created_at
      DateTime :updated_at
      DateTime :last_curated_at
      Bignum :share_count
      String :image
      
      primary_key [:id]
      
      index [:url]
      index [:url], :name=>:links_url_key, :unique=>true
    end
    
    create_table(:recipients, :ignore_index_errors=>true) do
      String :id, :null=>false
      String :email, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      String :schedule, :text=>true
      String :next_digest_job_id, :text=>true
      String :token, :text=>true, :null=>false
      
      primary_key [:id]
      
      index [:email], :name=>:recipients_email_key, :unique=>true
    end
    
    create_table(:schema_info) do
      Integer :version, :default=>0, :null=>false
    end
    
    create_table(:curators_links, :ignore_index_errors=>true) do
      foreign_key :curator_id, :curators, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :link_id, :links, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:curator_id, :link_id]
      
      index [:curator_id]
      index [:link_id]
    end
    
    create_table(:digests, :ignore_index_errors=>true) do
      String :id, :null=>false
      foreign_key :recipient_id, :recipients, :type=>String, :key=>[:id], :on_delete=>:cascade
      DateTime :created_at
      DateTime :updated_at
      
      primary_key [:id]
      
      index [:recipient_id]
    end
    
    create_table(:interests_links, :ignore_index_errors=>true) do
      foreign_key :interest_id, :interests, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :link_id, :links, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:interest_id, :link_id]
      
      index [:interest_id]
      index [:link_id]
    end
    
    create_table(:interests_recipients, :ignore_index_errors=>true) do
      foreign_key :interest_id, :interests, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :recipient_id, :recipients, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:interest_id, :recipient_id]
      
      index [:interest_id]
      index [:recipient_id]
    end
    
    create_table(:digests_links, :ignore_index_errors=>true) do
      foreign_key :digest_id, :digests, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      foreign_key :link_id, :links, :type=>String, :null=>false, :key=>[:id], :on_delete=>:cascade
      
      primary_key [:digest_id, :link_id]
      
      index [:digest_id]
      index [:link_id]
    end
  end
end
