# Dados iniciais. Rode com `bin/rails db:seed` (o bin/setup já faz isso).
# find_or_create_by! deixa o seed "idempotente": rodar duas vezes não duplica nada.
[
  { name: "Ana",    color: "#e50914" },
  { name: "Bruno",  color: "#2563eb" },
  { name: "Kids",   color: "#f59e0b" }
].each do |attrs|
  Profile.find_or_create_by!(name: attrs[:name]) do |profile|
    profile.color = attrs[:color]
  end
end

puts "Perfis: #{Profile.pluck(:name).join(', ')}"
