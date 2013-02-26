include "ecae.thrift"

service Snake_workerService extends ecae.EcaeService{
  /**
   * notify the queue change for snake.
   * op_type: 0 (Add a new queue), 1 (Delete an old queue)
   * If succeed, return 0; Otherwise 1
   */
  bool notify_queue_change(1:string queue_name, 2:i32 op_type),
  void test(),
}
