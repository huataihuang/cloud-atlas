...
 presets: [
    [
      //'classic',
      '@docusaurus/preset-classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          //path: 'docs',
          routeBasePath: 'arch',
          sidebarPath: './sidebars.js',
...
  ],
  plugins: [
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'discovery',
        path: 'discovery',
        routeBasePath: 'discovery',
        sidebarPath: './sidebars.js',
        // ... other options
      },
    ],
  ],

 themeConfig:
       items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Architecture',
          },
          {
            to: '/discovery/intro',
            position: 'left',
            label: 'Discovery',
            activeBaseRegex: '/Discovery/',
          },
          {to: '/blog', label: 'Blog', position: 'left'},
...
