- Link nyc open data with lottery data
- Front end
- Users/Authentication
- User saved queries
- User email alerts
<!-- 

https://maps.googleapis.com/maps/api/geocode/json?address={ADDRESS&}key={KEY}

%{body: %{results: [result | rest]}} ->
    address = result.formated_address
    location = result.geometry.location # lat,lng
    postal_code = Enum.find(result.address_components, fn
        %{types: ["postal_code"], long_name: postal_code} -> postal_code
        _ -> false 
    end) -->