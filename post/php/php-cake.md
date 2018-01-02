# cake

## Read DB Configuration Settings From a Cake Shell?
  App::uses('ConnectionManager', 'Model');
  $dataSource = ConnectionManager::getDataSource('default');
  $username = $dataSource->config['login'];
