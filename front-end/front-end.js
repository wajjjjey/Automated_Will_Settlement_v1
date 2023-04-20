const submitButton = document.getElementById("submit-button");
submitButton.addEventListener("click", async (event) => {
  event.preventDefault();

  const formData = new FormData(event.target.form);
  const data = {
    executors: [
      formData.get("Trusted-Party-1"),
      formData.get("Trusted-Party-2"),
    ],
  };

  const response = await fetch("/create-will", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  const result = await response.json();
  console.log(result);
});
