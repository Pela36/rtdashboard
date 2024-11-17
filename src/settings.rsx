<Screen
  id="settings"
  _hashParams={[]}
  _searchParams={[]}
  title={null}
  urlSlug=""
>
  <Include src="./header3.rsx" />
  <Frame
    id="$main3"
    enableFullBleed={false}
    isHiddenOnDesktop={false}
    isHiddenOnMobile={false}
    padding="8px 12px"
    sticky={null}
    type="main"
  >
    <Container
      id="container5"
      _gap="0px"
      footerPadding="4px 12px"
      headerPadding="4px 12px"
      padding="12px"
      showBody={true}
    >
      <Header>
        <Text
          id="containerTitle6"
          value="#### Container title"
          verticalAlign="center"
        />
      </Header>
      <View id="2f074" viewKey="View 1">
        <Container
          id="container6"
          footerPadding="4px 12px"
          headerPadding="4px 12px"
          padding="12px"
          showBody={true}
          showHeader={true}
        >
          <Header>
            <Text
              id="containerTitle7"
              value="#### Kubernetes"
              verticalAlign="center"
            />
          </Header>
          <View id="2f074" viewKey="View 1">
            <TextInput
              id="textInput2"
              label="IP"
              labelPosition="top"
              placeholder="{{ kubeIP.value }}"
            />
            <TextInput
              id="textInput3"
              label="Bearer Token"
              labelPosition="top"
              placeholder="**************"
            />
            <Button
              id="button2"
              heightType="auto"
              style={{ ordered: [{ background: "#034c11" }] }}
              text="APPLY"
            >
              <Event
                event="click"
                method="setValue"
                params={{ ordered: [{ value: "{{ textInput2.value }}" }] }}
                pluginId="kubeIP"
                type="state"
                waitMs="0"
                waitType="debounce"
              />
              <Event
                event="click"
                method="setValue"
                params={{ ordered: [{ value: "{{ textInput3.value }}" }] }}
                pluginId="kubeBearer"
                type="state"
                waitMs="0"
                waitType="debounce"
              />
            </Button>
          </View>
        </Container>
        <Container
          id="container7"
          footerPadding="4px 12px"
          headerPadding="4px 12px"
          padding="12px"
          showBody={true}
          showHeader={true}
        >
          <Header>
            <Text
              id="containerTitle8"
              value="#### Prometheus"
              verticalAlign="center"
            />
          </Header>
          <View id="2f074" viewKey="View 1">
            <TextInput
              id="textInput4"
              label="IP"
              labelPosition="top"
              placeholder="{{ prometheusUrl.value }}"
            />
            <TextInput
              id="textInput5"
              label="Bearer Token"
              labelPosition="top"
              placeholder="************"
            />
            <Button
              id="button3"
              heightType="auto"
              style={{ ordered: [{ background: "#034c11" }] }}
              text="APPLY"
            >
              <Event
                event="click"
                method="setValue"
                params={{ ordered: [{ value: "{{ textInput4.value }}" }] }}
                pluginId="prometheusUrl"
                type="state"
                waitMs="0"
                waitType="debounce"
              />
              <Event
                event="click"
                method="setValue"
                params={{ ordered: [{ value: "{{ textInput5.value }}" }] }}
                pluginId="prometheusBearer"
                type="state"
                waitMs="0"
                waitType="debounce"
              />
            </Button>
          </View>
        </Container>
      </View>
    </Container>
  </Frame>
</Screen>
