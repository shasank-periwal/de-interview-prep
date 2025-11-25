class transaction:
    def __init__(self, transactions):
        self.transactions = transactions

    def clean_transactions(self):
        temp = []
        for trn in self.transactions:
            if trn["amount"] < 0 or trn["status"].upper() == "FAILED":
                continue
            temp.append(trn)
        self.transactions = temp

    def total_amount_per_user(self, user_id):
        amount = 0
        for trn in self.transactions:
            if trn["user_id"] == user_id:
                amount += trn["amount"]
        return amount

    def total_amount_for_each_user(self):
        amount_per_user = {}
        for trn in self.transactions:
            if trn["user_id"] in amount_per_user.keys():
                amount_per_user[trn["user_id"]] = amount_per_user[trn["user_id"]] + trn["amount"]
            else:
                amount_per_user[trn["user_id"]] = trn["amount"]

        return amount_per_user

    # list of dict
    def total_amount_for_each_user_list(self):
        amount_per_user = {}
        for trn in self.transactions:
            if trn["user_id"] in amount_per_user.keys():
                amount_per_user[trn["user_id"]] = amount_per_user[trn["user_id"]] + trn["amount"]
            else:
                amount_per_user[trn["user_id"]] = trn["amount"]

        return amount_per_user

    def get_valid_transactions(self):
        return self.transactions


transactions = [
    {"txn_id": 1, "user_id": 101, "amount": 200, "status": "success"},
    {"txn_id": 2, "user_id": 101, "amount": -50, "status": "success"},
    {"txn_id": 3, "user_id": 102, "amount": 300, "status": "failed"},
    {"txn_id": 4, "user_id": 101, "amount": 100, "status": "success"},
    {"txn_id": 5, "user_id": 102, "amount": 500, "status": "success"},
]

t = transaction(transactions)
t.clean_transactions()
print(t.total_amount_per_user(101))
print(t.total_amount_for_each_user())