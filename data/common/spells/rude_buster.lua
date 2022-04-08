local spell, super = Class(Spell, "rude_buster")

function spell:init()
    super:init(self)

    -- Display name
    self.name = "Rude Buster"

    -- Battle description
    self.effect = "Rude\nDamage"
    -- Menu description
    self.description = "Deals moderate Rude-elemental damage to\none foe. Depends on Attack & Magic."

    -- TP cost
    self.cost = 50

    -- Target mode (party, enemy, or none/nil)
    self.target = "enemy"

    -- Tags that apply to this spell
    self.tags = {"rude", "damage"}
end

function spell:getCastMessage(user, target)
    return "* "..user.chara.name.." used RUDE BUSTER!"
end

function spell:onCast(user, target)
    local buster_finished = false
    local anim_finished = false
    local function finishAnim()
        anim_finished = true
        if buster_finished then
            Game.battle:finishAction()
        end
    end
    if not user:setAnimation("battle/rude_buster", finishAnim) then
        anim_finished = false
        user:setAnimation("battle/attack", finishAnim)
    end
    Game.battle.timer:after(10/30, function()
        Assets.playSound("snd_rudebuster_swing")
        local x, y = user:getRelativePos(user.width, user.height/2, Game.battle)
        local tx, ty = target:getRelativePos(target.width/2, target.height/2, Game.battle)
        local blast = RudeBusterBeam(false, x, y, tx, ty, function(pressed)
            local damage = math.ceil((user.chara:getStat("magic") * 5) + (user.chara:getStat("attack") * 11) - (target.defense * 3))
            if pressed then
                damage = damage + 30
                Assets.playSound("snd_scytheburst")
            end
            target:flash()
            target:hurt(damage, user)
            buster_finished = true
            if anim_finished then
                Game.battle:finishAction()
            end
        end)
        blast.layer = BATTLE_LAYERS["above_ui"]
        Game.battle:addChild(blast)
    end)
    return false
end

return spell