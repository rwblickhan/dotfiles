function bump_last_updated_date
    sd 'lastUpdatedDate: \d\d\d\d-\d\d-\d\d' "lastUpdatedDate: "(date +%Y-%m-%d)
end
