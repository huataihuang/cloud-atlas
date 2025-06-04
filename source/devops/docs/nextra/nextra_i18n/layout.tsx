type LayoutProps = Readonly<{
  children: ReactNode
  params: Promise<{
    lang: string
  }>
}>

const RootLayout: FC<LayoutProps> = async ({ children, params }) => {
  const { lang } = await params
  const dictionary = await getDictionary(lang)
  let pageMap = await getPageMap(`/${lang}`)

  if (lang === 'en') {
    pageMap = [
      ...pageMap,
      {
        name: 'remote',
        route: '/remote',
        children: [graphqlYogaPageMap],
        title: 'Remote'
      },
      graphqlEslintPageMap
    ]
  }
  ...
