for i in {130..300}; do
    j=$((i*5000))
    echo psql -h prod-pg.hdmap.mmtdev.com -U postgres  data_collection_prod -p 5444 -c 'select * from normal_keys order by id limit 5000 offset '"$j" 
    psql -h prod-pg.hdmap.mmtdev.com -U postgres  data_collection_prod -p 5444 -c 'select * from normal_keys order by id limit 5000 offset '"$j" > /dev/null || echo "Corrupted chunk read" 
done

