import unittest
import json
import os

from flask_rag_api import app

class FlaskRAGApiTestCase(unittest.TestCase):
    """
    测试 Flask 提供的 RAG API 接口和 chat 接口。
    使用 Flask 内置的 test_client() 进行请求模拟测试。
    """

    def setUp(self):
        """
        测试初始化，获取 Flask 应用的测试客户端实例。
        """
        self.client = app.test_client()
        self.client.testing = True

    def test_retrieve_endpoint(self):
        """
        测试 '/retrieve' 接口，验证接口响应的状态码和返回的 JSON 数据结构。
        """
        response = self.client.post(
            '/retrieve',
            json={
                'query': '什么是牛顿第一定律？',
                'similarity_top_k': 3
            }
        )
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIsInstance(data, dict)
        self.assertIn('result', data)
        self.assertIsInstance(data['result'], str)
        print("接口返回的数据:", data['result'])

    def test_chat_endpoint(self):
        """
        测试 '/api/chat' 接口，确保多轮对话功能正常。
        """
        conversation_id = 'test_conversation_123'
        response1 = self.client.post(
            '/api/chat',
            json={
                'conversation_id': conversation_id,
                'message': '什么是等差数列？'
            }
        )
        self.assertEqual(response1.status_code, 200)
        data1 = json.loads(response1.data)
        self.assertIn('answer', data1)
        self.assertIsInstance(data1['answer'], str)
        print("第一次回答:", data1['answer'])

        response2 = self.client.post(
            '/api/chat',
            json={
                'conversation_id': conversation_id,
                'message': '请举一个等差数列的例子。'
            }
        )
        self.assertEqual(response2.status_code, 200)
        data2 = json.loads(response2.data)
        self.assertIn('answer', data2)
        self.assertIsInstance(data2['answer'], str)
        print("第二次回答（多轮）:", data2['answer'])

    def test_missing_query_param(self):
        """
        测试请求缺少必要参数 'query' 时，接口应返回400错误状态。
        """
        response = self.client.post(
            '/retrieve',
            json={
                'similarity_top_k': 3
            }
        )
        self.assertEqual(response.status_code, 400)
        data = json.loads(response.data)
        self.assertIn('error', data)
        self.assertEqual(data['error'], "'query' parameter is required.")

    def test_invalid_method(self):
        """
        测试错误的 HTTP 方法(GET)，期望接口返回405 Method Not Allowed。
        """
        response = self.client.get('/retrieve')
        self.assertEqual(response.status_code, 405)

    def test_chat_missing_params(self):
        """
        测试 '/api/chat' 接口缺少必要参数时的响应。
        """
        response_no_id = self.client.post(
            '/api/chat',
            json={'message': '什么是等差数列？'}
        )
        self.assertEqual(response_no_id.status_code, 400)
        data_no_id = json.loads(response_no_id.data)
        self.assertIn('error', data_no_id)
        self.assertEqual(data_no_id['error'], "conversation_id is required")

        response_no_msg = self.client.post(
            '/api/chat',
            json={'conversation_id': 'test123'}
        )
        self.assertEqual(response_no_msg.status_code, 400)
        data_no_msg = json.loads(response_no_msg.data)
        self.assertIn('error', data_no_msg)
        self.assertEqual(data_no_msg['error'], "message is required")

if __name__ == '__main__':
    unittest.main()