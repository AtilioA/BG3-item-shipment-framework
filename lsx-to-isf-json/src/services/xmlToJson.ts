import { GameObjectData } from "./parseGameObjects";

// TODO: Extend with interfaces/types for better type checking
export function parseXML(xmlString: string): string[] {
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(xmlString, "text/xml");
  const mapKeys: string[] = [];
  const gameObjects = xmlDoc.getElementsByTagName("node");

  for (let gameObject of Array.from(gameObjects)) {
      if (gameObject.getAttribute("id") === "GameObjects") {
          const mapKey = gameObject.querySelector("[id='MapKey']");
          if (mapKey) {
              mapKeys.push(mapKey.getAttribute("value") || '');
          }
      }
  }
  return mapKeys;
}

export function constructJSON(gameData: GameObjectData[]): object {
    // TODO: use actual JSON from ISF
  const items = gameData.map((data) => ({
    "TemplateUUID": data.templateUUID,
    "Send": {
      "Quantity": 1, // Here, you can specify the amount of the item which you would like to spawn in.
      "To": { // In this section, you may specify all the destinations you wish to spawn the item into, like the Camp Chests and the player's inventory.
          "CampChest": { // Player1, 2, 3, and 4, specify which camp chest you would like to place your item into. To support all four possible players in multi-player, mark all of these variables as true. Chests not present in the camp will simply be ignored during shipment.
              "Player1Chest": true, // Orange chest (host's chest in single-player)
              "Player2Chest": true, // Green chest
              "Player3Chest": true, // Pink chest
              "Player4Chest": true // Blue chest
          },
          // "Host" represents the current character selected by the player. This could mean a character other than the Avatar selected during character creation. It also means the host of the current game session, even in a single-player. Setting this variable to true will spawn your item directly into the host's inventory.
          "Host": false // While this option has been included so that mod authors can give items directly to the player, to avoid cluttering them, it is strongly encouraged only to set this variable to true IF, and ONLY IF it is REQUIRED that your items are spawned in the player's inventory.
      }, // If you want your item to be spawned into only player inventories, and not any camp chests, set all CampChest variables to false, and set the Host variable to true.
      "On": { // This section tells ISF when to try to spawn your item into the game. This will still check for the existence of your item as you have specified in the "CheckExistence" section below, and will only spawn your item if it is not found in the specified categories, but it will try to do so at the specified times.
          "SaveLoad": true, // If you want to try to spawn your item into the game when the player loads a save, set this variable to true.
          "DayEnd": false // If you want to try to spawn your item into the game at the end of every day (during night, just before actual long rest), set this variable to true.
      },
      "NotifyPlayer": true, // If you want the player to receive a notification when the item is spawned into their inventory, set this variable to true.
      "Check": { // This section is dedicated to checking whether the player has the item already or if they've reached a certain level or Act.
          "ItemExistence": { // This section tells ISF whether to check if the item is currently inside of the camp chests and player inventories. Both sections can be used, and are checked at the same time (AND logic). If you want ISF to always spawn your item regardless of whether it is already in the game, set all variables to false.
              "CampChest": { // If these variables are set to true, and your item is found in NONE of the specified camp chests, ISF will spawn your item where you have specified in the "To" section.
                  "Player1Chest": true, // Orange chest (Host in single-player, or the first player in multi-player)
                  "Player2Chest": true, // Green chest (Second player in multi-player)
                  "Player3Chest": true, // Pink chest (Third player in multi-player)
                  "Player4Chest": true // Blue chest (Fourth player in multi-player)
              },
              "PartyMembers": { // If these variables are set to true, and your item is found in NONE of the specified inventories, ISF will spawn your item where you have specified in the "To" section.
                  "ActiveParty": true, // Specifies whether to check on inventories of party the player's current party (includes player character)
                  "AtCamp": true // Specifies whether to check on follower inventories while they are at camp, and not in your current party.
              },
              "FrameworkCheck": true // When this variable is set to true, ISF will do an internal check as to whether it has already spawned your item into the game. It's advised not to rely solely on this, since users uninstalling ISF and then reinstalling it will cause this check to fail. Upon uninstallation, users must confirm that they are aware of this fact.
          },
          "PlayerProgression": { // UNIMPLEMENTED: This section will be used in the future to check if the player has reached a certain level or act in the game before spawning your item.
              "Level": 1, // If you want to check if the player has reached a certain level in the game before spawning your item, set this variable to the level you want to check for.
              "Act": 1 // If you want to check if the player has reached a certain act in the game before spawning your item, set this variable to the act number you want to check for.
          }
      }
    }
  }));

  return {
      "FileVersion": 1,
      "Items": items
  };
}
