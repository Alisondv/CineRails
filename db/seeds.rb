# Dados iniciais. Rode com `ruby bin/rails db:seed` (o bin/setup já faz isso).
# find_or_create_by! deixa o seed idempotente: rodar de novo não duplica nada.
#
# Só existe UMA conta aqui: a de demonstração, usada na apresentação do projeto.
# O e-mail e a senha dela ficam documentados no README (não são segredo: é só
# um dado de apresentação, visto por qualquer colega que clonar o repositório).
conta_demo = User.find_or_create_by!(email: "demo@cinerails.test") do |user|
  user.password = "cinerails123"
end

# find_or_create_by! dentro de conta_demo.profiles: o perfil já nasce ligado
# a essa conta, nunca "solto" no banco.
conta_demo.profiles.find_or_create_by!(name: "Demo") do |profile|
  profile.color = Profile::COLORS.first
end

puts "Conta de demonstração: #{conta_demo.email} (senha: cinerails123)"
puts "Perfis da conta demo: #{conta_demo.profiles.pluck(:name).join(', ')}"
