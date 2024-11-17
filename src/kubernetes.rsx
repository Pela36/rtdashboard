<Screen
  id="kubernetes"
  _hashParams={[]}
  _searchParams={[]}
  title={null}
  urlSlug=""
>
  <RESTQuery
    id="getData"
    enableTransformer={true}
    headers={'[{"key":"Authorization","value":"{{ kubeBearer.value }}"}]'}
    isMultiplayerEdited={false}
    query="http://{{ kubeIP.value }}/api/v1/pods?"
    resourceName="REST-WithoutResource"
    resourceTypeOverride=""
    transformer="const podData = data; // Replace with your actual Retool query reference

// Helper function to calculate age from the creation timestamp
const calculatePodAge = (creationTimestamp) => {
  const now = new Date();
  const creationDate = new Date(creationTimestamp);
  const diffMs = now - creationDate;

  const seconds = Math.floor(diffMs / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 0) {
    return `${days}d`;
  } else if (hours > 0) {
    return `${hours}h`;
  } else if (minutes > 0) {
    return `${minutes}m`;
  } else {
    return `${seconds}s`;
  }
};

// Group pods by their namespaces and add age
const podsByNamespace = podData.items.reduce((acc, pod) => {
  const namespace = pod.metadata.namespace;
  if (!acc[namespace]) {
    acc[namespace] = [];
  }
  acc[namespace].push({
    name: pod.metadata.name,
    status: pod.status.phase,
    nodeName: pod.spec.nodeName,
    podIP: pod.status.podIP,
    age: calculatePodAge(pod.metadata.creationTimestamp), // Add age field here
  });
  return acc;
}, {});

return podsByNamespace;
"
  />
  <RESTQuery
    id="getData2"
    enableTransformer={true}
    headers={'[{"key":"Authorization","value":"{{ kubeBearer.value }}"}]'}
    isMultiplayerEdited={false}
    query="http://{{ kubeIP.value }}/api/v1/pods?"
    resourceName="REST-WithoutResource"
    resourceTypeOverride=""
    transformer={
      "// Assuming `data` is the Kubernetes API response from /api/v1/pods\nconst podData = data;\n\n// Helper function to calculate pod age from creation timestamp\nconst calculatePodAge = (creationTimestamp) => {\n  const now = new Date();\n  const creationDate = new Date(creationTimestamp);\n  const diffMs = now - creationDate;\n\n  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));\n  const hours = Math.floor((diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));\n  const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));\n  return days > 0 ? `${days}d` : hours > 0 ? `${hours}h` : `${minutes}m`;\n};\n\n// Transform pods data to match the specified structure\nconst podsByNamespace = podData.items.reduce((acc, pod) => {\n  const namespace = pod.metadata.namespace;\n  if (!acc[namespace]) acc[namespace] = [];\n\n  // Construct pod information in the requested format\n  const podInfo = {\n    name: pod.metadata.name,\n    status: pod.status.phase,\n    nodeName: pod.spec.nodeName,\n    podIP: pod.status.podIP || \"N/A\",\n    age: calculatePodAge(pod.metadata.creationTimestamp),\n    restartCount: pod.status.containerStatuses ? pod.status.containerStatuses.reduce((sum, c) => sum + (c.restartCount || 0), 0) : 0,\n    containers: pod.spec.containers.map(container => ({\n      name: container.name,\n      requests: container.resources.requests || {},\n      limits: container.resources.limits || {},\n    })),\n    conditions: pod.status.conditions ? pod.status.conditions.map(condition => ({\n      type: condition.type,\n      status: condition.status,\n      reason: condition.reason || '',\n      message: condition.message || ''\n    })) : []\n  };\n\n  acc[namespace].push(podInfo);\n  return acc;\n}, {});\n\nreturn podsByNamespace;\n"
    }
  />
  <State id="tempState" value="" />
  <Include src="./header2.rsx" />
  <Frame
    id="$main2"
    enableFullBleed={false}
    isHiddenOnDesktop={false}
    isHiddenOnMobile={false}
    padding="8px 12px"
    sticky={null}
    type="main"
  >
    <ListViewBeta
      id="listView1"
      data="{{ Object.keys(getData.data) }}"
      heightType="auto"
      itemWidth="200px"
      margin="0"
      numColumns={3}
      padding="0"
    >
      <Container
        id="container4"
        footerPadding="4px 12px"
        headerPadding="4px 12px"
        padding="12px"
        showBody={true}
        showHeader={true}
      >
        <Header>
          <Text
            id="containerTitle4"
            value="#### {{ item }}"
            verticalAlign="center"
          />
          <Text
            id="containerTitle5"
            horizontalAlign="center"
            style={{ ordered: [{ background: "rgba(3, 77, 18, 1)" }] }}
            value="#### NS"
            verticalAlign="center"
          />
        </Header>
        <View id="d1d93" viewKey="View 1">
          <Table
            id="table2"
            cellSelection="none"
            clearChangesetOnSave={true}
            data="{{ getData2.data[Object.keys(getData2.data)[i]] }}"
            defaultSelectedRow={{
              mode: "index",
              indexType: "display",
              index: 0,
            }}
            emptyMessage="No instances found"
            enableSaveActions={true}
            heightType="auto"
            showFooter={true}
            showHeader={true}
            templatePageSize={20}
          >
            <Column
              id="8c35e"
              alignment="left"
              cellTooltip="Pod status"
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
              size={66.5625}
              summaryAggregationMode="none"
              valueOverride={'{{ currentSourceRow.status === "Running" }}'}
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
              size={262.734375}
              summaryAggregationMode="none"
            />
            <Column
              id="056ba"
              alignment="left"
              editableOptions={{ showStepper: true }}
              format="tag"
              formatOptions={{ automaticColors: true }}
              groupAggregationMode="none"
              key="nodeName"
              label="Node"
              placeholder="Select option"
              position="center"
              size={166.375}
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
              key="podIP"
              label="Pod IP"
              optionList={{ mode: "mapped" }}
              placeholder="Enter value"
              position="center"
              size={165.015625}
              summaryAggregationMode="none"
            />
            <Column
              id="87d1c"
              alignment="left"
              editableOptions={{ showStepper: true }}
              format="tag"
              formatOptions={{ automaticColors: true }}
              groupAggregationMode="none"
              key="age"
              label="Age"
              placeholder="Select option"
              position="center"
              size={103.78125}
              summaryAggregationMode="none"
            />
            <Column
              id="0887f"
              alignment="center"
              editableOptions={{ showStepper: true }}
              format="decimal"
              formatOptions={{ showSeparators: true, notation: "standard" }}
              groupAggregationMode="sum"
              key="restartCount"
              label="Restarts"
              placeholder="Enter value"
              position="center"
              size={53.546875}
              summaryAggregationMode="none"
            >
              <Event
                event="clickCell"
                method="trigger"
                params={{ ordered: [] }}
                pluginId="getData2"
                type="datasource"
                waitMs="0"
                waitType="debounce"
              />
            </Column>
            <Column
              id="b4cb0"
              alignment="left"
              format="tags"
              formatOptions={{ automaticColors: true }}
              groupAggregationMode="none"
              hidden="true"
              key="containers"
              label="Containers"
              placeholder="Select options"
              position="center"
              size={100}
              summaryAggregationMode="none"
            />
            <Column
              id="98a88"
              alignment="left"
              format="tags"
              formatOptions={{ automaticColors: true }}
              groupAggregationMode="none"
              hidden="true"
              key="conditions"
              label="Conditions"
              placeholder="Select options"
              position="center"
              size={100}
              summaryAggregationMode="none"
            >
              <Event
                event="clickCell"
                method="trigger"
                params={{ ordered: [] }}
                pluginId="getData2"
                type="datasource"
                waitMs="0"
                waitType="debounce"
              />
            </Column>
            <Event
              event="selectRow"
              method="setValue"
              params={{ ordered: [{ value: "{{ self.data }}" }] }}
              pluginId="table2Data"
              type="state"
              waitMs="0"
              waitType="debounce"
            />
            <Event
              event="selectRow"
              method="setValue"
              params={{ ordered: [{ value: "{{ self.selectedRow}}" }] }}
              pluginId="selectedTbRow"
              type="state"
              waitMs="0"
              waitType="debounce"
            />
          </Table>
        </View>
      </Container>
      <Text
        id="formTitle2"
        _disclosedFields={{ array: ["color"] }}
        style={{ ordered: [{ color: "rgba(0, 0, 0, 1)" }] }}
        value="#### {{table1.selectedRow.name}}"
        verticalAlign="center"
      />
    </ListViewBeta>
  </Frame>
</Screen>
