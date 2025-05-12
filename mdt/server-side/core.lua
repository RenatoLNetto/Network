-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface('mdt', Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Operations = {}
local Permission = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPARTMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Department(Group)
  local source = source
  local Passport = vRP.Passport(source)
	Permission[Passport] = Passport and Group and vRP.HasPermission(Passport, Group) and Group or false
  return Permission[Passport]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Player()
  local source = source
  local Passport = vRP.Passport(source)
  local Permission = Permission[Passport]
  local Hierarchy, Name = vRP.HasPermission(Passport, Permission)
  local Player = {
    Name = vRP.FullName(Passport),
    Level = Hierarchy,
    Avatar = vRP.DiscordAvatar(Passport),
    Passport = Passport
  }
  local Permissions = Config.OtherPermissions[Permission] or Config.Permissions
  local Group = {
    Max = vRP.Permissions(Permission, 'Members'),
    Name = Name,
    Hierarchy = vRP.Hierarchy(Permission),
  }
  return { Group, Player, Permissions }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HOME
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Home()
  local source = source
  local Passport = vRP.Passport(source)
  local Permission = Permission[Passport]
  local Announcement = exports["oxmysql"]:query_async('SELECT * FROM mdt_creative_board WHERE Permission = @Permission', {
    Permission = Permission
  })
  local title = "Titúlo do Anúncio"
  local description = "Descrição do Anúncio"
  if Announcement and Announcement[1] then
    title = Announcement[1]["Title"] or title
    description = Announcement[1]["Description"] or description
  end
  return {
    Title = title,
    Description = description,
    Divisions = {
      { Amount = vRP.AmountService(Permission,1), Name = "Chefe" },
      { Amount = vRP.AmountService(Permission,2), Name = "Capitão" },
      { Amount = vRP.AmountService(Permission,3), Name = "Tenente" },
      { Amount = vRP.AmountService(Permission,4), Name = "Sargento" },
      { Amount = vRP.AmountService(Permission,5), Name = "Oficial" },
      { Amount = vRP.AmountService(Permission,6), Name = "Cadete" },
    },
  }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEBOARD
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.UpdateBoard(Title,Description)
  local source = source
  local Passport = vRP.Passport(source)

  local Permission = Permission[Passport]
  local Hierarchy = vRP.HasPermission(Passport, Permission)
  local Success = false

  if not Config['Permissions'][Board] == Hierarchy then
    TriggerClientEvent('painel:Notify', source, 'Erro', 'Você não possui permissões necessárias.', 'vermelho')
    return false
  end

  local Announcement = exports["oxmysql"]:query_async('SELECT * FROM mdt_creative_board WHERE Permission = @Permission', {
		Permission = Permission
	})

  if Announcement[1] then
    exports['oxmysql']:execute_async('UPDATE mdt_creative_board SET Title = ?, Description = ? WHERE Permission = ?', {
      Title,
      Description,
      Permission
    })
    Success = true
  else
    exports['oxmysql']:execute_async('INSERT INTO mdt_creative_board (Title, Description, Permission) VALUES (?, ?, ?)', {
      Title,
      Description,
      Permission
    })
    Success = true
  end

  if Success then
    local Name = vRP.FullName(Passport)
    local Groups = vRP.NumPermission(Permission)
    for _, Target in pairs(Groups) do
      if Target ~= source then
        TriggerClientEvent('Notify', Target, Name, '<b class=\'text-white\'>'..Title..'</b>: '.. Description, 'amarelo')
      end
    end
  end

  return Success
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEARCHOFFICER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.SearchOfficer(Search,Select)
    local source = source
    local Passport = vRP.Passport(source)
    local Permission = Permission[Passport]
    local Search = tostring(Search):lower()
    local Results = {}

    local Groups = vRP.DataGroups(Permission)
    for Target in pairs(Groups) do
        local Identity = vRP.Identity(Target)
        if Identity then
            local Found = false
            if tostring(Target) == Search then
                Found = true
            else
                if Identity['Name'] and Identity['Name']:lower():find(Search) then
                    Found = true
                elseif Identity['Lastname'] and Identity['Lastname']:lower():find(Search) then
                    Found = true
                end
            end

            if Found and vRP.HasPermission(Target, Permission) then
                Results[#Results+1] = {
                    Passport = Target,
                    Name = vRP.FullName(Target),
                }
            end
        end
    end

    return Results
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEARCHOFFICER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.SearchUser(Search,Select)
    local source = source
    local Passport = vRP.Passport(source)
    local Permission = Permission[Passport]
    local Search = tostring(Search):lower()
    local Results = {}

    local Consult = vRP.Query("accounts/All")
    for _, Account in pairs(Consult) do
      local Characters = vRP.Query("characters/Characters", { License = Account.License })
      for _, Character in pairs(Characters) do
        local Identity = vRP.Identity(Character.id)
        if Identity then
            local Found = false
            if tostring(Character.id) == Search then
                Found = true
            else
                if Identity['Name'] and Identity['Lastname']:lower():find(Search) then
                    Found = true
                elseif Identity['name'] and Identity['name2']:lower():find(Search) then
                    Found = true
                end
            end

            if Found and vRP.HasPermission(Character.id, Permission) then
                Results[#Results+1] = {
                    Passport = Character.id,
                    Name = vRP.FullName(Character.id),
                    Wanted = false
                }
            end
        end
      end
    end

    return Results
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETBANK 
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Bank()
  local source = source
  local Passport = vRP.Passport(source)
	local Permission = Permission[Passport]
  local Balance = vRP.Permissions(Permission, 'Bank')

  local Transactions = exports['oxmysql']:query_async('SELECT * FROM painel_creative_transactions WHERE Permission = @Permission LIMIT 10', {
      Permission = Permission
  })

  local Extract = {}
  for _, Data in ipairs(Transactions) do
    local Name = vRP.FullName(Data['Passport'])
    local TargetName = vRP.FullName(Data['Transfer'])
        Extract[#Extract+1] = {
            Player = { Passport = Data['Passport'], Name = Name },
            To = { Passport = Data['Transfer'], Name = TargetName },
            Type = Data['Type'],
            Value = Data['Value'],
            Date = Data['Date']
        }
  end

  return { Balance, Extract }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSITBANK 
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.DepositBank(Value)
    local source = source
    local Passport = vRP.Passport(source)

    if not Value or Value <= 0 then
        TriggerClientEvent('painel:Notify', source, 'Erro', 'Valor inválido para depósito.', 'vermelho')
        return false
    end

    local Permission = Permission[Passport]
    if vRP.PaymentBank(Passport, Value, true) then
        exports['oxmysql']:insert_async('INSERT INTO painel_creative_transactions (Type, Passport, Value, Date, Permission) VALUES (?, ?, ?, ?, ?)', {
            "Deposit",
            Passport,
            Value,
            os.time(),
            Permission
        })
		
        vRP.PermissionsUpdate(Permission, "Bank", "+", Value)

        TriggerClientEvent('painel:Notify', source, 'Sucesso', 'Depósito de <b class=\'text-white\'>$' .. Value .. '</b> realizado com sucesso.', 'verde')
        return true
    else
        TriggerClientEvent('painel:Notify', source, 'Erro', 'Saldo insuficiente para depósito.', 'vermelho')
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAWBANK 
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.WithdrawBank(Value)
  local source = source
  local Passport = vRP.Passport(source)
  local Permission = Permission[Passport]
  local Hierarchy = vRP.HasPermission(Passport, Permission)

  if Active[Permission] then
		return
	end

  if not Config['Permissions']['Bank']['Withdraw'] == Hierarchy then
      TriggerClientEvent('mdt:Notify', source, 'Erro', 'Você não possui permissões necessárias.', 'vermelho')
      return false
  end

  if not Value or Value <= 0 then
      TriggerClientEvent('mdt:Notify', source, 'Erro', 'Valor inválido para saque.', 'vermelho')
      return false
  end

  local Balance = vRP.Permissions(Permission, 'Bank')
  local Tax = math.floor(Value * (Config['BankTaxWithdraw'] or 0))

  if Balance < (Value + Tax) then
      TriggerClientEvent('mdt:Notify', source, 'Erro', 'Saldo insuficiente.', 'vermelho')
      return false
  end

  Active[Permission] = true
  vRP.PermissionsUpdate(Permission, "Bank", "-", Value + Tax)

  exports['oxmysql']:insert_async('INSERT INTO painel_creative_transactions (Type, Passport, Value, Date, Permission) VALUES (?, ?, ?, ?, ?)', {
      "Withdraw",
      Passport,
      Value,
      os.time(),
      Permission
  })

  vRP.GenerateItem(Passport, 'dollar', Value, true)
  if Tax > 0 then
    TriggerClientEvent('mdt:Refresh',source)
  end
  TriggerClientEvent('mdt:Notify', source, 'Sucesso', 'Saque de <b class=\'text-white\'>$' .. Value .. '</b> realizado com uma taxa de <b class=\'text-white\'>$' .. Tax .. '</b> aplicada.', 'verde')

  Active[Permission] = nil
  return { Balance - Value - Tax, { Passport = Passport, Name = vRP.FullName(Passport) } }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERBANK 
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.TransferBank(Target,Value)
  local source = source
  local Passport = vRP.Passport(source)
  local Permission = Permission[Passport]
  local Hierarchy, Title = vRP.HasPermission(Passport, Permission)
    
  if Active[Permission] then
		return
	end
    
	if not Config['Permissions']['Bank']['Withdraw'] == Hierarchy then
		TriggerClientEvent('mdt:Notify', source, 'Erro', 'Você não possui permissões necessárias.', 'vermelho')
		return
	end

  if not Target or not Value or Value <= 0 then
      TriggerClientEvent('mdt:Notify', source, 'Erro', 'Dados inválidos para transferência.', 'vermelho')
      return false
  end

  local Balance = vRP.Permissions(Permission, 'Bank')
  local Tax = math.floor(Value * (Config['BankTaxWithdraw'] or 0))
  if Balance < (Value + Tax) then
      TriggerClientEvent('mdt:Notify', source, 'Erro', 'Saldo insuficiente na conta da organização.', 'vermelho')
      return false
  end

  Active[Permission] = true
  vRP.PermissionsUpdate(Permission, "Bank", "-", Value + Tax)

  exports['oxmysql']:insert_async('INSERT INTO painel_creative_transactions (Type, Passport, Value, Transfer, Date, Permission) VALUES (\'Transfer\', ?, ?, ?, ?, ?)', {
      Passport,
      Value,
      Target,
      os.time(),
      Permission
  })

  vRP.GiveBank(Target, Value, true)
	if Tax > 0 then
		TriggerClientEvent('mdt:Refresh', source)
	end
	TriggerClientEvent('mdt:Notify',
		source,
		'Sucesso',
		'Transferência de <b class=\'text-white\'>$' .. Value .. '</b> para o passaporte <b class=\'text-white\'>' .. Target .. '</b> realizada com uma taxa de <b class=\'text-white\'>$' .. Tax .. '</b> aplicada.',
		'verde'
	)
  local Source = vRP.Source(Target)
  if Source then
      TriggerClientEvent('Notify', Source, 'Sucesso', '<b class=\'text-white\'>' .. Title .. '</b> fez uma transferência de <b class=\'text-white\'>$' .. Value .. '</b> para você.', 'verde', 10000)
  end

  Active[Permission] = nil

  local Name = vRP.FullName(Target)

  return {
      Passport = Target,
      Name = Name,
      Date = os.time()
  }
end

AddEventHandler("onResourceStart", function(resource)
  if resource == GetCurrentResourceName() then
      print("^5[Five Community]^0 Resource Autenticado com sucesso!")
      print("^2Desenvolvido por: ^1BKVINI.OFC^0 - Powered by ^5Five Community^0")
  end
end)



