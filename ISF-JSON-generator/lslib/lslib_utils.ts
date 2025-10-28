import path from 'path';
import dotnet from 'node-api-dotnet/net8.0';

const LSLIB_DLL = 'LSLib.dll';
const TOOL_SUBDIR = path.join('Tools', path.sep);

const elasticDlls: string[] = ['Elastic.Transport.dll', 'Elastic.Clients.Elasticsearch.dll'];
const storyCompilerDlls: string[] = ['StoryCompiler.dll', 'StoryDecompiler.dll'];
const converterAppDll: string[] = ['ConverterApp.dll'];
const illegalDlls: string[] = [...elasticDlls, ...storyCompilerDlls, ...converterAppDll];

const convertDirs = ['[PAK]_UI', '[PAK]_Armor', '[PAK]_Effects', 'RootTemplates', 'MultiEffectInfos', 'Assets', 'UI', 'Effects', 'LevelMapValues', 'Localization', 'Shapeshift'];

const illegalFiles = ['Icons_Items.lsx'];

const virtualTextureRegex = /Textures_[\d]+/;
const hotfixPatchRegex = /Patch[\d]+_Hotfix[\d]+/;

let DLL_PATHS: string[];
let LSLIB: any;
const lslibPath = 'Tools/LSLib.dll';
const lslibToolsPath = path.join(lslibPath, TOOL_SUBDIR);

export function getFormats() {
    return {
        dll: '.dll',
        loca: '.loca',
        xml: '.xml',
        lsb: '.lsb',
        lsf: '.lsf',
        lsj: '.lsj',
        lsfx: '.lsfx',
        lsbc: '.lsbc',
        lsbs: '.lsbs',
        lsx: '.lsx',
        pak: '.pak'
    };
}

export function dirSeparator(filePath: string): string {
    filePath = path.normalize(filePath);
    return filePath.startsWith(path.sep) ? filePath.slice(1) : filePath;
}

export function baseNamePath(filePath: string, ext: string): string {
    return filePath.substring(0, (filePath.length - ext.length));
}

async function loadDlls() {
    for (let i = 0; i < DLL_PATHS.length; i++) {
        try {
            dotnet.load(path.normalize(DLL_PATHS[i]));
        }
        catch (Error) {
            console.error(Error);
        }
    }
}

export async function LOAD_LSLIB() {
    try {
        const response = await fetch(lslibPath);
        if (response.ok) {
            DLL_PATHS = await FIND_FILES(getFormats().dll, lslibPath);
        } else {
            console.error('LSLib.dll not found at ' + lslibPath + '.');
            return null;
        }
    } catch (error) {
        console.error('Error loading LSLib.dll:', error);
        return null;
    }

    await loadDlls();

    // @ts-ignore
    return dotnet.LSLib.LS;
}

export async function FIND_FILES(targetExt: string = getFormats().lsf, filesPath: string = '**/*'): Promise<string[]> {
    let filesList: string[] = [];
    let globToSearch: string;
    const nonRecursiveGlob = '*';
    const recursiveGlob = '**/*';

    if (targetExt === getFormats().dll) {
        globToSearch = nonRecursiveGlob;
        const fileDir = `${filesPath}/${globToSearch}${targetExt}`;
        filesList = (await FIND_FILES(fileDir)).map(file => dirSeparator(file));
    } else if (targetExt === getFormats().pak) {
        globToSearch = recursiveGlob;
        const fileDir = `${filesPath}/${globToSearch}${targetExt}`;
        filesList = (await FIND_FILES(fileDir)).map(file => dirSeparator(file));
    } else {
        filesList = (await FIND_FILES(`${filesPath}${targetExt}`)).map(file => dirSeparator(file));
    }

    return FILTER_PATHS(filesList) as string[];
}

export function FILTER_PATHS(filesPath: string | string[]): string | string[] | undefined {
    let excludedFiles: string[] = [];
    excludedFiles = excludedFiles;

    if (Array.isArray(filesPath)) {
        const filteredPaths: string[] = [];

        for (let i = 0; i < filesPath.length; i++) {
            const temp_path = FILTER_PATHS(path.normalize(filesPath[i])) as string | undefined;

            if (temp_path) {
                filteredPaths.push(dirSeparator(path.normalize(temp_path)));
            }
        }
        return filteredPaths;
    } else if (typeof (filesPath) == 'string') {
        const temp_path = filesPath.split(path.sep);
        const temp_ext = path.extname(filesPath);

        for (let i = 0; i < temp_path.length; i++) {
            const temp_name = path.basename(filesPath, getFormats().pak);
            if (temp_ext === getFormats().dll && !illegalDlls.includes(path.basename(filesPath))) {
                return filesPath;
            } else if (
                temp_ext === getFormats().pak &&
                !(virtualTextureRegex.test(temp_name) ||
                    hotfixPatchRegex.test(temp_name))
            ) {
                return filesPath;
            } else if (
                (
                    !excludedFiles.includes(filesPath) &&
                    convertDirs.includes(temp_path[i]) &&
                    !illegalFiles.includes(path.basename(filesPath))
                )
            ) {
                return filesPath;
            }
        }
    }
}

export {
    LSLIB,
};
