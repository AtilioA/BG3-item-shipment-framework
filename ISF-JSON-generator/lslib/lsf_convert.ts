import { getFormats, LOAD_LSLIB, FIND_FILES, LSLIB } from './lslib_utils';

async function processLsf(file: string): Promise<any> {
    await LOAD_LSLIB();

    const ResourceLoadParameters = LSLIB.ResourceLoadParameters;
    const Game = LSLIB.Enums.Game;

    const load_params = ResourceLoadParameters.FromGameVersion(Game.BaldursGate3);

    // const ResourceConversionParameters = LSLIB.ResourceConversionParameters;
    // const conversion_params = ResourceConversionParameters.FromGameVersion(Game.BaldursGate3);

    const ResourceUtils = LSLIB.ResourceUtils;

    let temp_lsf = '';
    try {
        temp_lsf = ResourceUtils.LoadResource(file, load_params);
        // No need to save the file, just return the in-memory resource
        return temp_lsf;
    } catch (error) {
        console.info(error);
    }
}

async function processLsxAndLsf(folderPath: string): Promise<any[]> {
    // Find all .lsx files in the folder
    // const lsxFiles = await FIND_FILES(getFormats().lsx, folderPath);

    // Find all .lsf files in the folder
    const lsfFiles = await FIND_FILES(folderPath, getFormats().lsf);
    console.log('lsxFiles', lsfFiles);

    const gameObjectData: any[] = [];

    // // Process .lsx files
    // for (const lsxFile of lsxFiles) {
    //     const parsed = await parseRootTemplate(lsxFile);
    //     gameObjectData.push(...parsed);
    // }

    // Process .lsf files
    for (const lsfFile of lsfFiles) {
        const lsfData = await processLsf(lsfFile);
        console.log(lsfData);
        const parsed = parseRootTemplateFromLsf(lsfData);
        console.log(parsed);
        gameObjectData.push(...parsed);
    }

    return gameObjectData;
}

function parseRootTemplateFromLsf(lsfData: any): any {
    // Implement this function to parse the in-memory .lsf data
    // and return the same data structure as parseRootTemplate
}

export { processLsf, processLsxAndLsf, parseRootTemplateFromLsf };
