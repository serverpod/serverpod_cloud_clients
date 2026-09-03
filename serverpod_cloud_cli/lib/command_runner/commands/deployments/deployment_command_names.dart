class DeploymentCommandNames {
  const DeploymentCommandNames({
    required this.show,
    required this.list,
    required this.log,
  });

  final String show;
  final String list;
  final String log;

  static const public = DeploymentCommandNames(
    show: 'status deployment show',
    list: 'status deployment list',
    log: 'status deployment log',
  );

  static const legacy = DeploymentCommandNames(
    show: 'deployment show',
    list: 'deployment list',
    log: 'deployment build-log',
  );
}
