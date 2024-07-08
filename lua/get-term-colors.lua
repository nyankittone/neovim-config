if os.execute [[ test "`tput colors`" -gt 8 ]] == 0 then
  return true
else
  return false
end

