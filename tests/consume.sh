for i in $(seq 0 2); do
  res=$(curl -s -X GET localhost:8080 -d "{\"offset\":$i}")
  value=$(echo $res | jq -r '.record.value' | base64 -d)
  echo $res
  echo value: $value
done
