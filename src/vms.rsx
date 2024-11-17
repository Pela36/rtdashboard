<Screen
  id="vms"
  _hashParams={[]}
  _searchParams={[]}
  title="Default Page"
  urlSlug=""
>
  <Folder id="vmAction">
    <RESTQuery
      id="outNet"
      isMultiplayerEdited={false}
      notificationDuration={4.5}
      query={
        'http://{{ prometheusUrl.value }}/api/v1/query?query=sum(rate(node_network_transmit_bytes_total{device="eth0"}[5m])) by (instance_ip)'
      }
      resourceName="REST-WithoutResource"
      resourceTypeOverride=""
      showSuccessToaster={false}
      transformer=""
    />
    <RESTQuery
      id="incNet"
      isMultiplayerEdited={false}
      notificationDuration={4.5}
      query={
        'http://{{ prometheusUrl.value }}/api/v1/query?query=sum(rate(node_network_receive_bytes_total{device="eth0"}[5m])) by (instance)'
      }
      resourceName="REST-WithoutResource"
      resourceTypeOverride=""
      showSuccessToaster={false}
      transformer=""
    />
    <RESTQuery
      id="vmDISK"
      isMultiplayerEdited={false}
      notificationDuration={4.5}
      query={
        'http://{{ prometheusUrl.value }}/api/v1/query?query=100 * (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}))'
      }
      resourceName="REST-WithoutResource"
      resourceTypeOverride=""
      showSuccessToaster={false}
      transformer=""
    />
    <RESTQuery
      id="vmRAM"
      isMultiplayerEdited={false}
      notificationDuration={4.5}
      query="http://{{ prometheusUrl.value }}/api/v1/query?query=100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

"
      resourceName="REST-WithoutResource"
      resourceTypeOverride=""
      showSuccessToaster={false}
      transformer=""
    />
    <RESTQuery
      id="startVM"
      bodyType="raw"
      isMultiplayerEdited={false}
      query="/projects/{{ project.value }}/zones/{{ selectedZone.value }}/instances/{{ selectedVM.value }}/start
"
      resourceDisplayName="GoogleComputeAPI"
      resourceName="1c4cbdd4-e1ce-480a-8c9e-4647d1fbd0ff"
      resourceTypeOverride=""
      runWhenModelUpdates={false}
      type="POST"
    />
    <RESTQuery
      id="stopVM"
      bodyType="raw"
      isMultiplayerEdited={false}
      query="/projects/{{ project.value }}/zones/{{ selectedZone.value }}/instances/{{ selectedVM.value }}/stop
"
      resourceDisplayName="GoogleComputeAPI"
      resourceName="1c4cbdd4-e1ce-480a-8c9e-4647d1fbd0ff"
      resourceTypeOverride=""
      runWhenModelUpdates={false}
      type="POST"
    />
    <RESTQuery
      id="vmCPU"
      isMultiplayerEdited={false}
      notificationDuration={4.5}
      query={
        'http://{{ prometheusUrl.value }}/api/v1/query?query=100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) by (instance_ip) * 100)'
      }
      resourceName="REST-WithoutResource"
      resourceTypeOverride=""
      showSuccessToaster={false}
      transformer=""
    />
  </Folder>
  <RESTQuery
    id="fetchZones"
    enableTransformer={true}
    isMultiplayerEdited={false}
    notificationDuration={4.5}
    query="/projects/{{ project.value }}/zones/"
    resourceDisplayName="GoogleComputeAPI"
    resourceName="1c4cbdd4-e1ce-480a-8c9e-4647d1fbd0ff"
    showSuccessToaster={false}
    transformer="let zones = data.items;
let zoneNames = zones.map(zone => {
  return { name: zone.name };
});
return zoneNames;
"
  />
  <RESTQuery
    id="fetchVMs"
    enableTransformer={true}
    isMultiplayerEdited={false}
    notificationDuration={4.5}
    query="/projects/{{ project.value }}/zones/{{ selectedZone.value }}/instances?"
    resourceDisplayName="GoogleComputeAPI"
    resourceName="1c4cbdd4-e1ce-480a-8c9e-4647d1fbd0ff"
    showSuccessToaster={false}
    transformer={
      '// Assume the raw data is stored in `data` variable\nconst instances = data.items || [];\nconst project = data.id.split(\'/\')[1]; // Extract project ID\n\n// Map through each instance and transform it into a simpler object\nconst transformedInstances = instances.map((instance) => {\n  const networkInterface = instance.networkInterfaces[0] || {}; // primary network interface\n  const accessConfig = networkInterface.accessConfigs ? networkInterface.accessConfigs[0] : {};\n\n  return {\n    project: project, // Add project directly\n    id: instance.id,\n    name: instance.name,\n    status: instance.status,\n    machineType: instance.machineType.split("/").pop(), // extract machine type name\n    zone: instance.zone.split("/").pop(), // extract zone name\n    internalIP: networkInterface.networkIP || "N/A", // internal IP\n    externalIP: accessConfig.natIP || "N/A", // external IP\n  };\n});\n\n// Return the transformed array for use in Retool components\nreturn transformedInstances;\n'
    }
  >
    <Event
      event="success"
      method="run"
      params={{
        ordered: [
          {
            src: "// Ensure vmsList.value is initialized as an array\nconst currentVmsList = Array.isArray(vmsList.value) ? vmsList.value : [];\n\n// Append the new data from the query to the existing data\nconst updatedVmsList = currentVmsList.concat(fetchVMs.data || []);\n\n// Remove duplicate entries by ID\nconst uniqueVmsList = [...new Map(updatedVmsList.map(item => [item.id, item])).values()];\n\n// Set vmsList to the updated array\nvmsList.setValue(uniqueVmsList);\n",
          },
        ],
      }}
      pluginId=""
      type="script"
      waitMs="0"
      waitType="debounce"
    />
  </RESTQuery>
  <Function id="transformer1" />
  <State id="vmsList" value="[]" />
  <Include src="./header.rsx" />
  <Frame
    id="$main"
    isHiddenOnDesktop={false}
    isHiddenOnMobile={false}
    padding="8px 12px"
    sticky={false}
    type="main"
  >
    <Text
      id="title1"
      _disclosedFields={{ array: ["color"] }}
      style={{ ordered: [{ color: "#034c11" }] }}
      value="### Virtual Machines "
    />
    <Table
      id="table1"
      cellSelection="none"
      clearChangesetOnSave={true}
      data="{{ vmsList.value }}"
      defaultSelectedRow={{ mode: "index", indexType: "display", index: 0 }}
      emptyMessage="No instances found"
      enableSaveActions={true}
      primaryKeyColumnId="2221e"
      showFooter={true}
      showHeader={true}
      templatePageSize={20}
    >
      <Column
        id="8c35e"
        alignment="left"
        cellTooltip="This instance is running"
        cellTooltipMode="custom"
        editable={false}
        editableOptions={{ showStepper: true }}
        format="boolean"
        formatOptions={{
          automaticColors: true,
          trueIcon: "bold/interface-validation-check-circle",
          falseIcon: "bold/entertainment-control-button-stop-circle",
          trueColor: "#034c11",
          falseColor: "rgba(143, 0, 0, 1)",
        }}
        groupAggregationMode="none"
        key="status"
        label="Status"
        optionList={{ mode: "manual" }}
        placeholder="Enter value"
        position="center"
        size={67.5625}
        summaryAggregationMode="none"
        valueOverride={'{{ currentSourceRow.status === "RUNNING" }}'}
      />
      <Column
        id="2221e"
        alignment="left"
        editable={false}
        format="string"
        groupAggregationMode="none"
        key="name"
        label="Name"
        placeholder="Enter value"
        position="center"
        size={130.671875}
        summaryAggregationMode="none"
      />
      <Column
        id="056ba"
        alignment="left"
        editableOptions={{ showStepper: true }}
        format="tag"
        formatOptions={{ automaticColors: true }}
        groupAggregationMode="none"
        key="zone"
        label="Zone"
        placeholder="Select option"
        position="center"
        size={133.375}
        summaryAggregationMode="none"
      />
      <Column
        id="70390"
        alignment="left"
        cellTooltipMode="overflow"
        editableOptions={{ showStepper: true }}
        format="string"
        formatOptions={{ automaticColors: true }}
        groupAggregationMode="none"
        key="internalIP"
        label="Internal IP"
        optionList={{ mode: "mapped" }}
        placeholder="Enter value"
        position="center"
        size={103.015625}
        summaryAggregationMode="none"
      />
      <Column
        id="87d1c"
        alignment="left"
        editableOptions={{ showStepper: true }}
        format="string"
        formatOptions={{ showSeparators: true, notation: "standard" }}
        groupAggregationMode="none"
        key="externalIP"
        label="External IP"
        placeholder="Enter value"
        position="center"
        size={130.78125}
        summaryAggregationMode="none"
      />
      <Column
        id="f63cc"
        alignment="left"
        editableOptions={{ showStepper: true }}
        format="tag"
        formatOptions={{ automaticColors: true }}
        groupAggregationMode="none"
        key="machineType"
        label="Machine type"
        placeholder="Select option"
        position="center"
        size={159.15625}
        summaryAggregationMode="none"
      />
      <Column
        id="447f1"
        alignment="right"
        editableOptions={{ showStepper: true }}
        format="decimal"
        formatOptions={{ showSeparators: true, notation: "standard" }}
        groupAggregationMode="sum"
        hidden="true"
        key="id"
        label="ID"
        placeholder="Enter value"
        position="center"
        size={100}
        summaryAggregationMode="none"
      />
      <Column
        id="32cda"
        alignment="left"
        format="tag"
        formatOptions={{ automaticColors: true }}
        groupAggregationMode="none"
        key="project"
        label="Project"
        placeholder="Select option"
        position="center"
        referenceId="project"
        size={100}
        summaryAggregationMode="none"
      >
        <Event
          event="clickCell"
          method="trigger"
          params={{ ordered: [] }}
          pluginId="fetchVMs"
          type="datasource"
          waitMs="0"
          waitType="debounce"
        />
      </Column>
      <Event
        event="selectRow"
        method="setValue"
        params={{ ordered: [{ value: "{{ self.selectedRow.name }}" }] }}
        pluginId="selectedVM"
        type="state"
        waitMs="0"
        waitType="debounce"
      />
    </Table>
    <Container
      id="container2"
      footerPadding="4px 12px"
      headerPadding="4px 12px"
      hidden=""
      hoistFetching={true}
      padding="12px"
      showBody={true}
      style={{
        ordered: [
          { background: "rgba(6, 171, 39, 0.16)" },
          { border: "canvas" },
          { borderRadius: "16px" },
        ],
      }}
    >
      <Header>
        <Text
          id="containerTitle2"
          _disclosedFields={{ array: [] }}
          value="#### Container title"
          verticalAlign="center"
        />
      </Header>
      <View id="a83fc" viewKey="View 1">
        <Container
          id="container3"
          footerPadding="4px 12px"
          headerPadding="4px 12px"
          hidden=""
          hoistFetching={true}
          padding="12px"
          showBody={true}
          showHeader={true}
          style={{ ordered: [{ borderRadius: "8px\n" }] }}
        >
          <Header>
            <Text
              id="containerTitle3"
              _disclosedFields={{ array: ["color"] }}
              style={{ ordered: [{ color: "rgba(0, 0, 0, 1)" }] }}
              value="#### Details"
              verticalAlign="center"
            />
          </Header>
          <View id="cb8f1" viewKey="View 1">
            <TextInput
              id="textInput1"
              label=""
              labelPosition="top"
              placeholder="Enter project ID"
              value="{{ self.value }}"
            />
            <Select
              id="select1"
              data="{{ fetchZones.data }}"
              emptyMessage="No options"
              label=""
              labelPosition="top"
              labels="{{ item.name }}"
              overlayMaxHeight={375}
              placeholder="Select an option"
              showSelectionIndicator={true}
              values="{{ item.name }}"
            />
            <Button
              id="button1"
              style={{ ordered: [{ background: "#034c11" }] }}
              text="Load"
            >
              <Event
                event="click"
                method="setValue"
                params={{ ordered: [{ value: "{{ textInput1.value }}" }] }}
                pluginId="project"
                type="state"
                waitMs="0"
                waitType="debounce"
              />
              <Event
                event="click"
                method="setValue"
                params={{ ordered: [{ value: "{{ select1.value }}" }] }}
                pluginId="selectedZone"
                type="state"
                waitMs="0"
                waitType="debounce"
              />
            </Button>
          </View>
        </Container>
        <Form
          id="UpdateUserForm1"
          disableSubmit="{{ self.invalid }}"
          footerPadding="4px 12px"
          headerPadding="4px 12px"
          hidden="{{ table1.selectedRow == null }}"
          hoistFetching={true}
          initialData="{{ table1.selectedRow.data }}"
          padding="12px"
          requireValidation={true}
          resetAfterSubmit={true}
          showBody={true}
          showHeader={true}
          style={{
            ordered: [
              { border: "rgba(209, 209, 209, 0.39)" },
              { borderRadius: "8px" },
            ],
          }}
          styleContext={{ ordered: [{ borderRadius: "8px" }] }}
        >
          <Header>
            <Text
              id="formTitle1"
              _disclosedFields={{ array: ["color"] }}
              style={{ ordered: [{ color: "rgba(0, 0, 0, 1)" }] }}
              value="#### {{table1.selectedRow.name}}"
              verticalAlign="center"
            />
          </Header>
          <Body>
            <Text
              id="text2"
              _disclosedFields={{ array: [] }}
              value="##### RAM"
              verticalAlign="center"
            />
            <Text
              id="text1"
              _disclosedFields={{ array: [] }}
              value="#### CPU"
              verticalAlign="center"
            />
            <ProgressCircle
              id="progressCircle2"
              _disclosedFields={{ array: ["tooltipText", "fill"] }}
              horizontalAlign="center"
              style={{ ordered: [{ fill: "#034c11" }] }}
              value="{{ vmRAM.data.data.result.find(entry => entry.metric.instance_ip === table1.selectedRow.name)?.value[1] || 0 }}"
            />
            <ProgressCircle
              id="progressCircle1"
              _disclosedFields={{ array: ["tooltipText", "fill"] }}
              horizontalAlign="center"
              style={{ ordered: [{ fill: "#034c11" }] }}
              value="{{ 
  vmCPU.data.data.result.find(entry => entry.metric.instance_ip === table1.selectedRow.name)?.value[1] || 0 
}}"
            />
            <Divider
              id="divider1"
              _disclosedFields={{ array: [] }}
              textSize="default"
            />
            <Text
              id="text3"
              _disclosedFields={{ array: [] }}
              value="##### DISK"
              verticalAlign="center"
            />
            <ProgressBar
              id="progressBar1"
              label=""
              style={{ ordered: [{ fill: "#034c11" }] }}
              value="{{ vmDISK.data.data.result.find(entry => entry.metric.instance_ip === table1.selectedRow.name)?.value[1] || 0 }}"
            />
            <Divider
              id="divider2"
              _disclosedFields={{ array: [] }}
              textSize="default"
            />
            <Text id="text4" value="ID:" verticalAlign="center" />
            <Text
              id="text5"
              horizontalAlign="right"
              value="{{ table1.selectedRow.id }}"
              verticalAlign="center"
            />
            <Divider
              id="divider3"
              _disclosedFields={{ array: [] }}
              textSize="default"
            />
            <Button
              id="leftButton1"
              _disclosedFields={{ array: ["iconBefore", "label"] }}
              disabled="{{ table1.selectedRow.status === false }}
"
              iconBefore="bold/entertainment-control-button-stop"
              style={{ ordered: [{ background: "#034c11" }] }}
              text="STOP"
            >
              <Event
                event="click"
                method="trigger"
                params={{ ordered: [] }}
                pluginId="stopVM"
                type="datasource"
                waitMs="0"
                waitType="debounce"
              />
            </Button>
            <Button
              id="rightButton1"
              _disclosedFields={{ array: ["iconBefore", "label"] }}
              disabled="{{ table1.selectedRow.status === true }}
"
              hidden=""
              iconBefore="bold/entertainment-control-button-play"
              style={{ ordered: [{ background: "#034c11" }] }}
              text="START"
            >
              <Event
                event="click"
                method="trigger"
                params={{ ordered: [] }}
                pluginId="startVM"
                type="datasource"
                waitMs="0"
                waitType="debounce"
              />
            </Button>
          </Body>
          <Footer>
            <Button
              id="SubmitForm1"
              _disclosedFields={{ array: ["background", "borderRadius"] }}
              style={{
                ordered: [{ background: "#034c11" }, { borderRadius: "8px" }],
              }}
              submitTargetId="UpdateUserForm1"
              text="Save Changes"
            >
              <Event
                event="click"
                method="showNotification"
                params={{
                  ordered: [
                    {
                      options: {
                        ordered: [
                          { notificationType: "info" },
                          { title: "To edit data, connect your own resource." },
                          {
                            description:
                              "After connecting a resource, you can create read and write queries to interact with your data.",
                          },
                        ],
                      },
                    },
                  ],
                }}
                pluginId=""
                type="util"
                waitMs="0"
                waitType="debounce"
              />
            </Button>
          </Footer>
          <Event
            event="submit"
            method=""
            params={{ ordered: [] }}
            pluginId=""
            type="datasource"
            waitMs="0"
            waitType="debounce"
          />
        </Form>
      </View>
    </Container>
  </Frame>
</Screen>
