// run node server.js to run server

const express = require("express");
const bodyParser = require("body-parser");
const {
  createWill,
} = require("/home/ubuntuwaj/Will_Settlement/scripts/interact.js");

const app = express();
app.use(bodyParser.json());

app.post("/create-will", async (req, res) => {
  const {
    executors,
    assetNames,
    assetDescriptions,
    nftRecipients,
    tokenAmounts,
    tokenAddresses,
    tokenRecipients,
  } = req.body;

  try {
    const txHash = await createWill(
      executors,
      assetNames,
      assetDescriptions,
      nftRecipients,
      tokenAmounts,
      tokenAddresses,
      tokenRecipients
    );
    res.json({ success: true, txHash });
  } catch (error) {
    console.error(error);
    res.json({ success: false, error: error.message });
  }
});

app.listen(3000, () => {
  console.log("Server started on port 3000");
});
