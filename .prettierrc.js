// Based on https://github.com/ionic-team/prettier-config/blob/v1.0.1/index.js
module.exports = {
    arrowParens: 'avoid',
    bracketSpacing: true,
    jsxBracketSameLine: false,
    jsxSingleQuote: false,
    quoteProps: 'consistent',
    semi: true,
    singleQuote: true,
    tabWidth: 4,
    printWidth: 100,
    trailingComma: 'all',
    plugins: ['prettier-plugin-java'],
    overrides: [
        {
            files: ['*.java'],
            options: {
                printWidth: 100,
                tabWidth: 4,
                useTabs: false,
                trailingComma: 'none',
            },
        },
    ],
};
