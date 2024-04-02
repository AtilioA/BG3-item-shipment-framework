---@class HelperMessages: Helper
Messages = _Class:Create("HelperMessages", Helper)

Messages.Handles = {
  mailbox_added_to_camp_chest = "h7b114c9fge69cg4fbfg9389g430a24de7726",
  mailbox_moved_to_camp_chest = "h7b114c9fge69cg4fbfg9389g430a24de7726",
  mod_shipped_item_to_mailbox = "h1baaa2bdgfce5g4685g9b67g9055ee45c1dc"
}

function Messages.ResolveMessagesHandles()
  local messages = {
    mailbox_added_to_camp_chest = Ext.Loca.GetTranslatedString("h7b114c9fge69cg4fbfg9389g430a24de7726"),
    mailbox_moved_to_camp_chest = Ext.Loca.GetTranslatedString("h7b114c9fge69cg4fbfg9389g430a24de7726"),
  }
  return messages
end

-- TODO: move to VCHelpers, potentially make it generic (any amount of dynamic content)
--- Update a localized message with dynamic content
-- @param handle string The handle of the localized message to update
-- @param dynamicContent string The dynamic content to replace the placeholder with
function Messages.UpdateLocalizedMessage(handle, dynamicContent)
  -- Retrieve the current translated string for the given handle
  local currentMessage = Ext.Loca.GetTranslatedString(handle)

  -- Replace the placeholder [1] with the dynamic content. The g flag is for global replacement.
  local updatedMessage = string.gsub(currentMessage, "%[1%]", dynamicContent)

  -- Update the translated string with the new content, altering it during runtime. Any GetTranslatedString calls will now return this updated message.
  Ext.Loca.UpdateTranslatedString(handle, updatedMessage)
end

Messages.ResolvedMessages = Messages.ResolveMessagesHandles()
